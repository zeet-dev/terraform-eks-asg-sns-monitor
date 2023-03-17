variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "sns_subscription_endpoint" {
  type = string
}

variable "sns_subscription_protocol" {
  default = "https"
}

variable "zeet_cluster_id" {
  // optional
  default = ""
  description = "id for the zeet cluster record. optional: when non-empty, it will be used to look up self-managed ec2 node groups"
}
