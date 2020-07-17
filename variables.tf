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
  default = "jp-tok"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["jp-tok-1", "jp-tok-2", "jp-tok-3"]
}

locals {
  max_size = length(var.vpc_zone_names)
}
