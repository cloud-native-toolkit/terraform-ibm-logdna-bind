variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
}

variable "region" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The apikey used to access the IBM Cloud account"
}

variable "logdna_id" {
  type        = string
  description = "The id of the logdna instance that will be gound to the cluster"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = ""
}

variable "cluster_id" {
  type        = string
  description = "The identifier for the cluster"
  default     = ""
}

variable "private_endpoint" {
  type        = string
  description = "Flag indicating that the agent should be created with private endpoints"
  default     = "true"
}

variable "sync" {
  type        = string
  description = "Semaphore to synchronize activities between modules"
  default     = ""
}
