locals {
  tmp_dir           = "${path.cwd}/.tmp"
  role              = "Manager"
  cluster_type_file = "${local.tmp_dir}/cluster_type.out"
  bind              = true
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"

  clis = ["jq"]
}

resource null_resource print_names {

  provisioner "local-exec" {
    command = "echo 'Resource group name: ${var.resource_group_name}'"
  }
}

data "ibm_resource_group" "tools_resource_group" {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

resource "ibm_resource_key" "logdna_instance_key" {
  count = local.bind ? 1 : 0

  name                 = "${var.cluster_name}-key"
  resource_instance_id = var.logdna_id
  role                 = local.role

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

resource "null_resource" "logdna_bind" {
  count = local.bind ? 1 : 0

  triggers = {
    bin_dir = module.setup_clis.bin_dir
    cluster_id  = var.cluster_id
    instance_id = var.logdna_id
    ibmcloud_api_key = var.ibmcloud_api_key
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/bind-instance.sh '${self.triggers.cluster_id}' '${self.triggers.instance_id}' '${ibm_resource_key.logdna_instance_key[0].name}' '${var.private_endpoint}'"

    environment = {
      IBMCLOUD_API_KEY = nonsensitive(self.triggers.ibmcloud_api_key)
      BIN_DIR = self.triggers.bin_dir
      SYNC = var.sync
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/unbind-instance.sh '${self.triggers.cluster_id}' '${self.triggers.instance_id}'"

    environment = {
      IBMCLOUD_API_KEY = nonsensitive(self.triggers.ibmcloud_api_key)
      BIN_DIR = self.triggers.bin_dir
    }
  }
}
