############################
# Security Group
############################
resource "aws_security_group" "nat_sg" {
  name        = "nat-sg"
  description = "NAT instance SG"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nat-sg" }
}

############################
# ENI + EIP + Association
############################
resource "aws_network_interface" "nat_eni" {
  for_each          = local.public_subnet
  subnet_id         = each.value
  security_groups   = [aws_security_group.nat_sg.id]
  source_dest_check = false
  tags              = { Name = "nat-eni-${each.key}" }
}

resource "aws_eip" "nat_eip" {
  for_each = aws_network_interface.nat_eni
  domain   = "vpc"
  tags     = { Name = "nat-eip-${each.key}" }
}

resource "aws_eip_association" "nat_eip_assoc" {
  for_each             = aws_network_interface.nat_eni
  allocation_id        = aws_eip.nat_eip[each.key].id
  network_interface_id = each.value.id
}

############################
# Private Routes
############################
resource "aws_route" "private_default" {
  for_each               = local.private_rt
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_eni[each.key].id
}

############################
# IAM Role + Instance Profile
############################
resource "aws_iam_role" "nat_role" {
  name = "nat-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "nat_policy" {
  name = "nat-inline"
  role = aws_iam_role.nat_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ec2:ModifyInstanceAttribute", "ec2:AttachNetworkInterface", "ec2:DetachNetworkInterface", "ec2:Describe*"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "nat_profile" {
  name = "nat-instance-profile"
  role = aws_iam_role.nat_role.name
}

############################
# Launch Template + ASG
############################
data "aws_ami" "al2023_arm" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-arm64"]
  }
}

locals {
  nat_user_data = <<-EOT
    #!/bin/bash
    set -eux
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-nat.conf
    sysctl -p /etc/sysctl.d/99-nat.conf
    PUBLIC_IF=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    PRIVATE_IF="ens6"
    dnf install -y iptables-services
    iptables -F
    iptables -t nat -F
    iptables -t nat -A POSTROUTING -o $PUBLIC_IF -j MASQUERADE
    iptables -A FORWARD -i $PRIVATE_IF -o $PUBLIC_IF -j ACCEPT
    iptables -A FORWARD -i $PUBLIC_IF -o $PRIVATE_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
    service iptables save
    systemctl enable iptables
  EOT
}

resource "aws_launch_template" "nat_lt" {
  for_each      = local.public_subnet
  name_prefix   = "nat-lt-${each.key}-"
  image_id      = data.aws_ami.al2023_arm.id
  instance_type = var.nat_instance_type
  key_name      = "EKS-Master8"

  iam_instance_profile { name = aws_iam_instance_profile.nat_profile.name }

  network_interfaces {
    subnet_id                   = each.value
    security_groups             = [aws_security_group.nat_sg.id]
    associate_public_ip_address = true
  }

  user_data = base64encode(local.nat_user_data)
}

resource "aws_autoscaling_group" "nat_asg" {
  for_each            = aws_launch_template.nat_lt
  name                = "nat-asg-${each.key}"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [each.value.network_interfaces[0].subnet_id]

  launch_template {
    id      = each.value.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nat-${each.key}"
    propagate_at_launch = true
  }
}
