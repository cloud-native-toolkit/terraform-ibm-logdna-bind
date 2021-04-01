module "dev_tools_namespace" {
  source = "github.com/ibm-garage-cloud/terraform-cluster-namespace.git"

  cluster_type             = "ocp4"
  cluster_config_file_path = module.dev_cluster.config_file_path
  tls_secret_name          = ""
  name                     = var.namespace
}
