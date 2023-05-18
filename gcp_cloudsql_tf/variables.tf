variable "postgres_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "users" {
  description = "Map of users and their attributes, key is the user login"
  default     = {}
}

variable "database" {
  description = "Database name used for permission setup"
  type        = string
}

variable "vault_secret_path" {
  description = "Path to secret in local vault, used mainly to save the credentials instead of displaying them to the console"
  default     = ""
  type        = string
}

variable "expose_password" {
  description = "Expose password to Terraform output"
  default     = false
  type        = bool
}

variable "project" {
  description = "Project ID"
  type        = string
}

