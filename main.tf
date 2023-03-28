#############
# resources #
#############
# sns topic
resource "aws_sns_topic" "cloudwatch_events" {
  name = "zeet-eks-${var.cluster_name}-cloudwatch-events-${local.topic_suffix}"
}

resource "aws_sns_topic_policy" "allow_cloudwatch_events" {
  arn = aws_sns_topic.cloudwatch_events.arn
  policy = data.aws_iam_policy_document.sns_cloudwatch_events_topic_policy_document.json
}

resource "aws_sns_topic_subscription" "subscription" {
  endpoint  = var.sns_subscription_endpoint
  protocol  = var.sns_subscription_protocol
  topic_arn = aws_sns_topic.cloudwatch_events.arn
}

# cloudwatch event
module "asg_lifecycle_event" {
  source = "./asg_cloudwatch_event"

  event_identifier = "eks-${var.cluster_name}"
  asg_names        = local.asg_names
  event_target_arn = aws_sns_topic.cloudwatch_events.arn
}

############
#   data   #
############
data "aws_eks_node_groups" "all_node_groups" {
  cluster_name = var.cluster_name
}

data "aws_eks_node_group" "node_group" {
  for_each = {for name in data.aws_eks_node_groups.all_node_groups.names : name => name}

  cluster_name    = var.cluster_name
  node_group_name = each.value
}

data "aws_autoscaling_groups" "ec2_node_groups" {
  // when zeet_cluster_id is given, we can look up self-managed ec2 node groups
  count = var.zeet_cluster_id != "" ? 1 : 0

  filter {
    name   = "tag:ZeetClusterId"
    values = [var.zeet_cluster_id]
  }
}

data "aws_iam_policy_document" "sns_cloudwatch_events_topic_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.aws_account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.cloudwatch_events.arn,
    ]

    sid = "__default_statement_ID"
  }

  # allow cloudwatch events to publish to this topic
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CWE_Troubleshooting.html#NoMessagesPublishedSNS
  statement {
    sid = "Allow_Publish_Events"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.cloudwatch_events.arn,
    ]
  }
}

resource "random_id" "topic_id" {
  # 8 hex characters
  byte_length = 4
}

locals {
  # traverse eks node groups, collecting all asg names
  eks_node_group_asg_names = flatten([
    for ng in data.aws_eks_node_group.node_group : [
      for resource in ng.resources : [
        for asg in resource.autoscaling_groups : asg.name
      ]
    ]
  ])

  self_managed_node_group_asg_names = flatten([
    for ng in data.aws_autoscaling_groups.ec2_node_groups : [
      ng.names
    ]
  ])

  asg_names = toset(
    concat(
      local.eks_node_group_asg_names,
      local.self_managed_node_group_asg_names
    )
  )
  topic_suffix = random_id.topic_id.hex
}
