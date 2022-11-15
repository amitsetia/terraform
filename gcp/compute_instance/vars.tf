variable "gcp_machine_type" {
  type        = string
  description = "The GCP machine type (Example: e2-standard-2)"
}

variable "gcp_project" {
  type        = string
  default     = "viki-shared-network"
  description = "The GCP project ID (may be a alphanumeric slug) that the resources are deployed in. (Example: my-project-name)"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "The GCP region that the resources will be deployed in. (Ex. us-east1)"
}

variable "gcp_region_zone" {
  type        = string
  default     = "us-central1-a"
  description = "The GCP region availability zone that the resources will be deployed in. This must match the region. (Example: us-east1-a)"
}

variable "instance_name" {
  type        = string
  description = "The short name (hostname) of the VM instance that will become an A record in the DNS zone that you specify. (Example: app1)"
}
#variable "name" {
#  type        = string
#  description = "The short name (hostname) of the VM instance that will become an A record in the DNS zone that you specify. (Example: app1)"
#}

# Optional variables with default values

variable "disk_boot_size" {
  type        = string
  description = "The size in GB of the OS boot volume. (Default: 10)"
  default     = "10"
}

variable "disk_storage_enabled" {
  type        = bool
  description = "True to attach storage disk. False to only have boot disk. (Default: false)"
  default     = "false"
}

variable "disk_size" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 100)"
  default     = "50"
}

variable "disk_type" {
  type    = string
  default = "pd-standard"
}

variable "gcp_deletion_protection" {
  type        = bool
  description = "Enable this to prevent Terraform from accidentally destroying the instance with terraform destroy command. (Default: false)"
  default     = "false"
}

variable "external_ip" {
  type        = bool
  description = "Enable this to prevent Terraform from accidentally destroying the instance with terraform destroy command. (Default: false)"
  default     = "false"
}

variable "gcp_image" {
  type        = string
  description = "The GCP image name. (Default: ubuntu-1804-lts)"
  default     = "ubuntu-1804-lts"
}

variable "labels" {
  type        = map(any)
  description = "A single-level map/object with key value pairs of metadata labels to apply to the GCP resources. All keys should use underscores and values should use hyphens. All values must be wrapped in quotes."
  default     = {}
}

variable "business" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 100)"
}

variable "team" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 100)"
}

variable "environment" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 100)"
}

variable "subnetwork" {
  type        = string
  description = "subnetwork"
}

variable "network" {
  type        = string
  description = "subnetwork"
}

variable "instance_description" {
  type        = string
  description = "Purpose of the instance"
}

variable "instance_count" {
  description = "Number of instance needs to be created"
}

variable "disk_size_gb" {}
variable "resource_enabled" {
  type    = bool
  default = false
}
