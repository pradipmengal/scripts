provider "aws" {
  region = var.region
}

#---------------------------
# EKS Cluster IAM Role
# --------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# --------------------------
# EKS Cluster
# --------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids              = local.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]
}

# --------------------------
# Node Group IAM Role
# --------------------------
resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# --------------------------
# Traefik NLB IAM Policy
# --------------------------
resource "aws_iam_policy" "traefik_nlb_policy" {
  name        = "${var.cluster_name}-traefik-nlb-policy"
  description = "Allow Traefik to create NLB and manage ELB resources"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup",
          "elasticloadbalancing:*",
          "iam:CreateServiceLinkedRole",
          "iam:GetServerCertificate",
          "iam:ListServerCertificates"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "traefik_nlb_attach" {
  policy_arn = aws_iam_policy.traefik_nlb_policy.arn
  role       = aws_iam_role.node_role.name
}

# --------------------------
# Security Group for Worker Nodes
# --------------------------
resource "aws_security_group" "node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "EKS worker node security group"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow all traffic from within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.170.0.0/16"] # replace with your VPC CIDR if different
  }

  # Allow traffic from the security group itself (self-reference)
  ingress {
    description = "Allow all traffic from nodes in the same SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow kubelet → EKS API
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name                                        = "${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"

  }
}

resource "aws_security_group" "karpenter_node_sg" {
  name        = "${var.cluster_name}-karpenter-node-sg"
  description = "Security group for Karpenter nodes"
  vpc_id      = local.vpc_id

  # Node-to-node traffic
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow EKS control plane → kubelet
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    security_groups = [
      data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    ]
  }

  ingress {
    description = "EKS control plane to worker nodes"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [
      data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    ]
  }

  # Allow EKS control plane → HTTPS (node bootstrap)
  ingress {
    description = "EKS control plane to nodes (HTTPS bootstrap)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    ]
  }

  # Allow kubelet → EKS API
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internet access (ECR, SSM, etc)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                     = "${var.cluster_name}-karpenter-node-sg"
    "karpenter.sh/discovery" = var.cluster_name
  }
}

resource "aws_security_group_rule" "eks_api_from_karpenter_nodes" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.karpenter_node_sg.id

  description = "Allow Karpenter nodes to reach EKS API server"
}

# --------------------------
# EKS Node Group
# --------------------------
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = local.private_subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = [var.instance_type]

  remote_access {
    ec2_ssh_key               = var.key_pair_name
    source_security_group_ids = [aws_security_group.node_sg.id]
  }

  force_update_version = true

  depends_on = [
    null_resource.verify_nat_health,
    aws_eks_addon.vpc_cni,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.traefik_nlb_attach,
  ]

  labels = {
    node-type = "baseline"
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

# --------------------------
# EKS Addons
# --------------------------
#resource "aws_eks_addon" "vpc_cni" {
#  cluster_name                = aws_eks_cluster.main.name
#  addon_name                  = "vpc-cni"
#  resolve_conflicts_on_create = "OVERWRITE"
#  resolve_conflicts_on_update = "PRESERVE"
#  configuration_values = jsonencode({
#    "enableNetworkPolicy" : "true"
#  })
#  depends_on = [aws_eks_cluster.main]
#}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"

    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
      WARM_IP_TARGET           = "5"
    }
  })

  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_cluster.main]
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
}

#resource "aws_eks_addon" "node_monitoring" {
#  cluster_name                = aws_eks_cluster.main.name
#  addon_name                  = "eks-node-monitoring-agent"
#  resolve_conflicts_on_create = "OVERWRITE"
#  resolve_conflicts_on_update = "OVERWRITE"
#  depends_on                  = [aws_eks_cluster.main]
#}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_cluster.main]
}
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_cluster.main]
}

# --------------------------
# Verify NAT is healthy before node group
# --------------------------
resource "null_resource" "verify_nat_health" {
  depends_on = [aws_eks_cluster.main]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Verifying NAT instances are healthy before node group creation..."
      MAX_WAIT=300
      ELAPSED=0
      while [ $ELAPSED -lt $MAX_WAIT ]; do
        # Get all instances with nat in their name
        INSTANCE_IDS=$(aws ec2 describe-instances \
          --filters "Name=tag:Name,Values=nat-*" "Name=instance-state-name,Values=running" \
          --query "Reservations[*].Instances[*].InstanceId" \
          --output text)
        
        if [ -n "$INSTANCE_IDS" ]; then
          # Check status checks
          ALL_HEALTHY=true
          for instance_id in $INSTANCE_IDS; do
            STATUS=$(aws ec2 describe-instance-status \
              --instance-ids "$instance_id" \
              --query "InstanceStatuses[*].InstanceStatus.Status" \
              --output text 2>/dev/null || echo "initializing")
            if [ "$STATUS" != "ok" ]; then
              ALL_HEALTHY=false
              break
            fi
          done
          
          if [ "$ALL_HEALTHY" = true ]; then
            echo "All NAT instances are healthy and passing status checks."
            exit 0
          fi
        fi
        
        echo "Waiting for NAT instances... ($ELAPSED s / $MAX_WAIT s)"
        sleep 10
        ELAPSED=$((ELAPSED + 10))
      done
      
      echo "ERROR: NAT instances not healthy within $MAX_WAIT seconds"
      exit 1
    EOT
  }
}

