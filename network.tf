resource "ibm_is_vpc" "iac_iks_vpc" {
  name                      = "${var.project_name}-${var.environment}-vpc"
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
  tags                      = ["owner:${var.project_name}"]
  
  provisioner "local-exec" {
    command =<<EOT
      vpc_api_endpoint  = https://${var.region}.iaas.cloud.ibm.com
      echo $vpc_api_endpoint
      security_group_id = $(curl -X GET "$vpc_api_endpoint/v1/vpcs?version=2020-08-20&generation=2" -H "Authorization: Bearer $IC_IAM_TOKEN" | jq -r '.vpcs | .[] | select (.name=="${var.project_name}-${var.environment}-vpc") | .default_security_group.id')
      echo $security_group_id
      curl -X PATCH "$vpc_api_endpoint/v1/security_groups/$security_group_id?version=2020-08-20&generation=2" -H "Authorization: Bearer $IC_IAM_TOKEN" -d '{ "name": "${var.project_name}-${var.environment}-vpc-default-security-group" }'
      network_acl_id    = $(curl -X GET "$vpc_api_endpoint/v1/vpcs?version=2020-08-20&generation=2" -H "Authorization: Bearer $IC_IAM_TOKEN" | jq -r '.vpcs | .[] | select (.name=="${var.project_name}-${var.environment}-vpc") | .default_network_acl.id')
      echo $network_acl_id
      curl -X PATCH "$vpc_api_endpoint/v1/network_acls/$network_acl_id?version=2020-08-20&generation=2" -H "Authorization: Bearer $IC_IAM_TOKEN" -d '{ "name":"${var.project_name}-${var.environment}-vpc-default-network-acl" }'
    EOT
  }
}

resource "ibm_is_public_gateway" "iac_iks_public_gateway" {
    count          = local.max_size
    name           = "${var.project_name}-${var.environment}-public-gateway"
    zone           = var.vpc_zone_names[count.index]
    vpc            = ibm_is_vpc.iac_iks_vpc.id
    resource_group = data.ibm_resource_group.group.id
    tags           = ["owner:${var.project_name}"]
}

resource "ibm_is_vpc_address_prefix" "iac_iks_vpc_address_prefix" {
  count                    = local.max_size
  name                     = "${var.project_name}-${var.environment}-vpc-address-prefix-${format("%02s", count.index + 1)}"
  zone                     = var.vpc_zone_names[count.index]
  vpc                      = ibm_is_vpc.iac_iks_vpc.id
  cidr                     = "192.168.250.0/23"
}

resource "ibm_is_subnet" "iac_iks_subnet" {
  count                    = local.max_size
  name                     = "${var.project_name}-${var.environment}-subnet-${format("%02s", count.index + 1)}"
  zone                     = var.vpc_zone_names[count.index]
  vpc                      = ibm_is_vpc.iac_iks_vpc.id
  resource_group           = data.ibm_resource_group.group.id
  ipv4_cidr_block          = "192.168.250.0/24"
  public_gateway           = ibm_is_public_gateway.iac_iks_public_gateway[count.index].id
  depends_on               = [ibm_is_vpc_address_prefix.iac_iks_vpc_address_prefix]
}

resource "ibm_is_security_group_rule" "iac_iks_security_group_rule_tcp_k8s" {
  count     = local.max_size
  group     = ibm_is_vpc.iac_iks_vpc.default_security_group
  direction = "inbound"
  remote    = ibm_is_subnet.iac_iks_subnet[count.index].ipv4_cidr_block

  tcp {
    port_min = 30000
    port_max = 32767
  }
}
