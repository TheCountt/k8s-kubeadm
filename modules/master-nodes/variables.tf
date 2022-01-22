
variable "region" {}

variable "subnet_id" {}

variable "ami" {}

variable "instance_type" {}

variable "k8s-sg" {}


variable "key_name" {
  type    = string
  default = "k8s-kubeadm"
}

variable "master_ip_list" {
  default     = ["10.0.0.10", "10.0.0.11", "10.0.0.12"]
  description = "targeted ip adddresses"
  type        = list(any)
}



///////////////////////////////////////
# Not part of code

# variable "private_ip" {
#     default = ["master_ip_list"]
# }

#  variable "number_of_master_nodes" {
#      default = "3"
#  }