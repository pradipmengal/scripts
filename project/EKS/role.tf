###############################################################
# EBS CSI Driver – Terraform Setup for AWS EKS
# Compatible with Terraform AWS Provider v5+
###############################################################

# -------------------------------------------------------------
# Fetch EKS Cluster Identity
# -------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.name
}

# -------------------------------------------------------------
# Create IAM OIDC Provider for EKS
# -------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# -------------------------------------------------------------
# Create IAM Role for the EBS CSI Driver (IRSA)
# -------------------------------------------------------------
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# -------------------------------------------------------------
# Attach the AmazonEBSCSIDriverPolicy to the Role
# -------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}


