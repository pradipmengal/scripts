resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "random_password" "rds" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "rds" {
  name       = "${var.project_name}-${var.environment}-rds-credentials"
  kms_key_id = aws_kms_key.rds.arn
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds.result
  })
}

resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      "sg-067d2e1abe6ee63e9" # Replace with EKS SG later (recommended)
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = local.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "rds" {
  name   = "${var.project_name}-postgres17-params"
  family = "postgres17"

  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  tags = {
    Name = "${var.project_name}-postgres-params"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "17"
  auto_minor_version_upgrade = true

  instance_class = "db.t4g.small"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  password = random_password.rds.result

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 4
  backup_window           = "18:30-19:30"
  maintenance_window      = "sun:19:30-sun:20:30"

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn

  parameter_group_name = aws_db_parameter_group.rds.name

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  apply_immediately = false

  tags = {
    Name        = "${var.project_name}-postgres"
    Environment = var.environment
  }
}

