provider "aws" {
  region = var.region
}

# -------------------------------
# SQS Queue for Karpenter
# -------------------------------
resource "aws_sqs_queue" "karpenter_interruption" {
  name                       = var.sqs_queue_name
  message_retention_seconds  = 300
  visibility_timeout_seconds = 30

  tags = {
    Name        = var.sqs_queue_name
    Environment = var.environment
    Component   = "karpenter"
    ManagedBy   = "terraform"
  }
}

# -------------------------------
# EventBridge Rule
# -------------------------------
resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  name        = "${var.environment}-karpenter-interruption-rule"
  description = "EC2 interruption events for Karpenter"

  event_pattern = jsonencode({
    source = ["aws.ec2"]
    "detail-type" = [
      "EC2 Spot Instance Interruption Warning",
      "EC2 Instance Rebalance Recommendation",
      "EC2 Instance State-change Notification",
      "EC2 Scheduled Change"
    ]
  })
}

# -------------------------------
# EventBridge Target → SQS
# -------------------------------
resource "aws_cloudwatch_event_target" "karpenter_interruption" {
  rule      = aws_cloudwatch_event_rule.karpenter_interruption.name
  target_id = "karpenter-sqs"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

# -------------------------------
# Allow EventBridge → SQS
# -------------------------------
resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.karpenter_interruption.arn
      }
    ]
  })
}

