module "logdna-bind" {
  source = "./module"

  resource_group_name      = var.resource_group_name
  region                   = var.region
  ibmcloud_api_key         = var.ibmcloud_api_key
  cluster_id               = module.dev_cluster.id
  cluster_name             = module.dev_cluster.name
  cluster_config_file_path = module.dev_cluster.config_file_path
  tools_namespace          = module.dev_tools_namespace.name
  name                     = module.logdna.name
}
