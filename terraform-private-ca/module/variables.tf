variable "ca_common_name" {
  description = "CA Common Name"
  default     = "*.c.viki-consul-vault.internal"
}

variable "common_name" {
  description = "Common Name"
  default     = "*.c.viki-consul-vault.internal"
}

variable "organization_name" {
  description = "Organization Name"
  default     = "Viki, Inc."
}
