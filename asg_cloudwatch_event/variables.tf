variable "asg_names" {
  type = list(string)
}

variable "event_target_arn" {
  type = string
}

variable "event_identifier" {
  # included in the event rule name
  type = string
}