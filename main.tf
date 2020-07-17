provider "ibm" {
  generation = 2
  region     = var.region
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}
