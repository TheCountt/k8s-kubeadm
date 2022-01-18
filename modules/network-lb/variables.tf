variable "resource_tag" {}

variable "vpc_id" {}

variable "subnet_id" {}

variable "master_ip_list" {
  default     = ["10.0.1.10", "10.0.1.11", "10.0.1.12"]
  description = "targeted ip adddresses"
  type        = list(any)
}
