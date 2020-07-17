resource "ibm_container_vpc_cluster" "iac_iks_cluster" {
  name              = "${var.project_name}-${var.environment}-cluster"
  vpc_id            = ibm_is_vpc.iac_iks_vpc.id
  flavor            = var.flavor
  worker_count      = var.workers_count[0]
  kube_version      = var.k8s_version
  resource_group_id = data.ibm_resource_group.group.id
  zones {
    name      = var.vpc_zone_names[0]
    subnet_id = ibm_is_subnet.iac_iks_subnet[0].id
  }
}
