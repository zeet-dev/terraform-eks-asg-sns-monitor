# asg_couldwatch_event

A terraform module

Given list of `asg_names` and a cloudwatch `event_target_arn` (i.e. SNS topic), creates a
cloudwatch event rule for all autoscaling events from the AutosScalingGroups.