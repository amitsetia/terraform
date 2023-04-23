module "ca" {
  source             = "./ca"
  ca_common_name     = var.ca_common_name
  organization_name  = var.organization_name
  ca_public_key_path = "tls/ca.cert"
}



module "vault-cert" {
  source                = "./certificate"
  common_name           = var.common_name
  organization_name     = var.organization_name
  cert_private_key_path = "tls/vault_private_key.pem"
  dns_names             = ["vaulttest-0", "localhost"]
  ip_addresses          = ["127.0.0.1", ]
  ca_key_algorithm      = module.ca.ca_key_algorithm
  ca_private_key_pem    = module.ca.ca_private_key_pem
  ca_cert_pem           = module.ca.ca_cert_pem
  cert_public_key_path  = "tls/vault_wildcard.crt"
}


locals {
  tls_data = {
    vault_ca   = base64encode(module.ca.ca_cert_pem)
    vault_cert = base64encode(module.vault-cert.cert_pem)
    vault_pk   = base64encode(module.vault-cert.private_key_pem)
  }
}

locals {
  secret = jsonencode(local.tls_data)
}


resource "google_secret_manager_secret" "secret_tls" {
  #secret_id = var.tls_secret_id
  secret_id = "TestCert"
  project   = "gcp-project"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret_version_basic" {
  secret = google_secret_manager_secret.secret_tls.id

  secret_data = local.secret
}
