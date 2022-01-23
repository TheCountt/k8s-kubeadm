variable "region" {}

variable "vpc_cidr" {}

variable "enable_dns_support" {}

variable "enable_dns_hostnames" {}

variable "enable_classiclink" {}

variable "enable_classiclink_dns_support" {}

variable "subnet_cidr" {}

variable "service_cidr" {}

variable "all_ips" {}

variable "resource_tag" {}

variable "ingress" {
    type = list(number)
    description = "list in ports"
    default = [22, 6443, 80, 10250]
}