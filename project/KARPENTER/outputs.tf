output "karpenter_interruption_queue_name" {
  description = "SQS queue name for Karpenter interruption handling"
  value       = aws_sqs_queue.karpenter_interruption.name
}

output "karpenter_interruption_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.karpenter_interruption.arn
}

output "karpenter_interruption_queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.karpenter_interruption.id
}

