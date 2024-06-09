variable "region" {
  type    = string
  default = "us-west-1"
}

variable "profile" {}
variable "aws_load_balancer_controller_enabled" {
  type    = bool
  default = false
}