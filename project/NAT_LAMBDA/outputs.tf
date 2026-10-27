output "lambda_function_name" {
  value = aws_lambda_function.nat_eni_reattach.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.asg_events.arn
}

