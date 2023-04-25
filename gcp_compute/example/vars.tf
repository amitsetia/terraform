variable "project_id" {
  description = "The GCP project to use for integration tests"
  type        = string
  default     = "consul-vault"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "us-central1"
}

variable "subnetwork" {
  description = "The name of the subnetwork create this instance in."
  default     = ""
}

variable "service_account" {
  default = null
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
}

variable "tags" {
  type        = list(string)
  description = "Network tags, provided as a list"
  default     = ["vault"]
}

variable "labels" {
  type        = map(string)
  description = "Labels, provided as a map"
  default     = { "business" : "private", "environment" : "test", "team" : "platform" }
}

variable "target_size" {
  description = "The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set."
  default     = "1"
}


variable "metadata_key" {
  description = "The service account"
  type        = string
  default     = null

}
