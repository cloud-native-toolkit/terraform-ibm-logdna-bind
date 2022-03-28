module "logdna" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-log-analysis.git"

  resource_group_name      = var.resource_group_name
  region                   = var.region
  provision                = true
  name_prefix              = var.name_prefix
}
