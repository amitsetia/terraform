data "google_compute_network" "net" {
  name = var.gcp_region_zone
  #name   = var.subnetwork
  project = var.gcp_project

}

data "google_compute_subnetwork" "vikinet" {
  region  = var.gcp_region
  name    = var.subnetwork
  project = var.gcp_project
}

data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}



