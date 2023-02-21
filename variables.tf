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
