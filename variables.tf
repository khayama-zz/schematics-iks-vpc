variable "project_name" {
  default = "khayama"
}
variable "environment" {
  default = "iks"
}
variable "resource_group" {
  default = "khayama-rg"
}
variable "region" {
  default = "eu-de"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["eu-de-3"]
}

locals {
  max_size = length(var.vpc_zone_names)
}

variable "flavors" {
  type    = list(string)
  default = ["bx2.2x8"]
}
variable "workers_count" {
  type    = list(number)
  default = [3]
}
variable "k8s_version" {
  default = "1.18.4"
}
