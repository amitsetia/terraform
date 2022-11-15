terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}


# Create additional disk volume for instance
resource "google_compute_disk" "datadisk" {
  count   = var.disk_storage_enabled ? "${var.instance_count}" : 0
  project = var.gcp_project

  labels = var.labels
  size   = var.disk_size_gb
  name   = "${var.instance_name}-${count.index}-datadisk"
  type   = var.disk_type
  zone   = data.google_compute_zones.available.names[count.index]
}

# Create an external IP for the instance
resource "google_compute_address" "eip" {

  count        = var.external_ip ? "${var.instance_count}" : 0
  address_type = "EXTERNAL"
  description  = "External IP for ${var.instance_description}"
  name         = "${var.instance_name}-${count.index + 1}-network-ip"
  region       = var.gcp_region
  project      = var.gcp_project
}


# Create a Google Compute Engine VM instance
resource "google_compute_instance" "instance" {
  count               = var.instance_count
  name                = "${var.instance_name}-${count.index}"
  machine_type        = var.gcp_machine_type
  zone                = data.google_compute_zones.available.names[count.index]
  deletion_protection = var.gcp_deletion_protection
  project             = var.gcp_project


  boot_disk {
    initialize_params {
      type  = "pd-ssd"
      size  = var.disk_boot_size
      image = var.gcp_image
    }
  }
  labels = {
    busines = var.business
    env     = var.environment
    tea     = var.team

  }

  dynamic "attached_disk" {
    for_each = var.disk_storage_enabled ? [""] : []
    content {
      source = google_compute_disk.datadisk[count.index].self_link
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.vikinet.self_link
    dynamic "access_config" {
      for_each = var.external_ip ? [""] : []
      content {
        nat_ip = google_compute_address.eip[count.index].address
      }
    }
  }



  metadata = {
    startup-script = var.disk_storage_enabled ? file("${path.module}/scripts/disk_mount.sh") : null
  }


  lifecycle {
    ignore_changes = [attached_disk]
  }

}
