module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc.git"

  resource_group_name = module.resource_group.name
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  name                = var.cluster_name
  worker_count        = var.worker_count
  ocp_version         = var.ocp_version
  exists              = var.cluster_exists
  name_prefix         = var.name_prefix
  vpc_name            = var.vpc_cluster
  vpc_subnets         = []
  vpc_subnet_count    = 0
  cos_id              = ""
}
