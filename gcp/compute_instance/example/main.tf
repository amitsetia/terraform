
#terraform {
#  backend "gcs" {
#    bucket = "vikiterraform"
#    prefix = "prod/redisamit"
#  }
#}


module "test_instance" {
  source = "../../compute_instance"

  # Required variables
  instance_count          = 2
  instance_name           = "redisamit"
  gcp_machine_type        = "e2-standard-2"
  gcp_project             = "viki-shared-network"
  gcp_region              = "us-central1"
  subnetwork              = "viki-prod-central"
  gcp_image               = "ubuntu-1804-bionic-v20221018"
  instance_description    = "test"
  gcp_deletion_protection = "false"
  network                 = "viki"
  external_ip             = "true"
  disk_storage_enabled    = "true"
  disk_type               = "pd-standard"
  disk_size_gb            = "20"


  business    = "viki"
  environment = "test"
  team        = "platform"


}

output "public_ip" {
  value = module.test_instance.public_ip
}

output "private_ip" {
  value = module.test_instance.private_ip
}

output "instancename" {
  value = module.test_instance.instancename
}

output "InstanceName-IP" {
  value = module.test_instance.detail
}

output "public-IP" {
  value = module.test_instance.detail
}
