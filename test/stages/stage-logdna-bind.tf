module "logdna-bind" {
  source = "./module"

  resource_group_name      = var.resource_group_name
  region                   = var.region
  ibmcloud_api_key         = var.ibmcloud_api_key
  cluster_id               = module.dev_cluster.id
  cluster_name             = module.dev_cluster.name
  logdna_id                = module.logdna.guid
  logdna_crn               = module.logdna.id
}
