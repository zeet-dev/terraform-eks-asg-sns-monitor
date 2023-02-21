output "sns_topic_arn" {
  value = aws_sns_topic.cloudwatch_events.arn
}

output "event_rule_arn" {
  value = module.asg_lifecycle_event.cloudwatch_event_rule_arn
}