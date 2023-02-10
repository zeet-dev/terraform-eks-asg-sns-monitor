locals {
  asg_autoscaling_event_rule_json = {
    "source" : ["aws.autoscaling"],
    "detail" : {
      "AutoScalingGroupName" : var.asg_names
    }
  }
}

module "cloudwatch_event" {
  source = "github.com/cloudposse/terraform-aws-cloudwatch-events.git?ref=0.6.1"

  name      = "asg-cloudwatch-event"
  namespace = "zeet"
  stage     = var.event_identifier

  cloudwatch_event_rule_description = "AutoScalingGroup lifecycle events"
  cloudwatch_event_rule_pattern     = local.asg_autoscaling_event_rule_json
  cloudwatch_event_target_arn       = var.event_target_arn
}

output "cloudwatch_event_rule_arn" {
  value = module.cloudwatch_event.aws_cloudwatch_event_rule_arn
}