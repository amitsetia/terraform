data "vault_generic_secret" "mypass"{
 path = "secret/path_of_superuser_password"
}

provider "postgresql" {
  scheme          = "gcppostgres"
  host            = "gcpproject:us-central1:testamit" // gcp_project.region.instance_name
  port            = 5432
  username        = "postgres"
  #password        = "XXXXX"
  password        = "${data.vault_generic_secret.mypass.data["password"]}"
  #sslmode         = "require"
  connect_timeout = 15
}


module "database_users" {
  source = "../"
  users = {
    "rudraapp" : {
      permissions : ["SELECT"]
      tables : ["company"]
  }
 } 
 
  #vault_secret_path      = var.vault_secret_path      // for storing password
  database               = var.database
  postgres_instance_name = var.instance               //fetch name by executing "gcloud sql instances list"
  project                = var.project                // Only two projects to select
