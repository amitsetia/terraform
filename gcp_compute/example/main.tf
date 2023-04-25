
provider "google" {

  project = var.project_id
  region  = var.region
}

resource "google_compute_address" "ip_address" {
  name = "external-ip"
}

locals {
  access_config = {
    nat_ip       = google_compute_address.ip_address.address
    network_tier = "PREMIUM"
  }
}

module "instance_template" {
  source          = "../instance_template"
  project_id      = "consul-vault"
  subnetwork      = "default"
  stack_type      = "IPV4_ONLY"
  service_account = { email = "compute-kms@consul-vault.iam.gserviceaccount.com", scopes = ["cloud-platform"] }
  name_prefix     = "simple"
  tags            = ["vault"]
  labels          = { "business" : "private", "environment" : "test", "team" : "platform" }
  access_config   = [local.access_config]

  /* image */
  source_image         = "ubuntu-2204-jammy-v20230421"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"


  startup_script = file("vault.sh")
}

module "mig" {
  source            = "../mig"
  project_id        = var.project_id
  region            = "us-central1"
  target_size       = "1"
  count             = "1"
  hostname          = "vault-prod-mig"
  instance_template = module.instance_template.self_link

  named_ports = [{ name = "vaulthttp"
  port = "8200" }, ]

  health_check_name = "mig-vault-hc"
  health_check = {
    type                = "vault"
    initial_delay_sec   = 120
    check_interval_sec  = 5
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 2
    response            = ""
    proxy_header        = "NONE"
    port                = 8200
    request             = ""
    request_path        = "/ui"
    host                = "localhost"
    enable_logging      = false
  }

}


# module "mig" {
#   source            = "../../../mig"
#   project_id        = var.project_id
#   region            = "asia-southeast1"
#   target_size       = "1"
#   hostname          = "vault-prod-mig"
#   instance_template = module.instance_template.self_link

#   health_check_name = "mig-vault-hc"
#   health_check = {
#     type                = "vault"
#     initial_delay_sec   = 120
#     check_interval_sec  = 5
#     healthy_threshold   = 2
#     timeout_sec         = 5
#     unhealthy_threshold = 2
#     response            = ""
#     proxy_header        = "NONE"
#     port                = 8200
#     request             = ""
#     request_path        = "/ui"
#     host                = "localhost"
#     enable_logging      = false
#   }
# }

# module "mig" {
#   source            = "../../../mig"
#   project_id        = var.project_id
#   region            = "europe-west1"
#   target_size       = "1"
#   hostname          = "vault-prod-mig"
#   instance_template = module.instance_template.self_link

#   health_check_name = "mig-vault-hc"
#   health_check = {
#     type                = "vault"
#     initial_delay_sec   = 120
#     check_interval_sec  = 5
#     healthy_threshold   = 2
#     timeout_sec         = 5
#     unhealthy_threshold = 2
#     response            = ""
#     proxy_header        = "NONE"
#     port                = 8200
#     request             = ""
#     request_path        = "/ui"
#     host                = "localhost"
#     enable_logging      = false
#   }
# }
