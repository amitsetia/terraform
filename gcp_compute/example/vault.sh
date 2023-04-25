#!/bin/bash
 export instance_id="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google)"
 export local_ipv4="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip -H Metadata-Flavor:Google)"

 sudo wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

 sudo echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

 sudo apt update && sudo apt install vault jq -y
 rm -rf /opt/vault/tls/*
 chmod 0755 /opt/vault/tls

    # vault-key.pem should be readable by the vault group only
 touch /opt/vault/tls/vault-key.pem
 chown root:vault /opt/vault/tls/vault-key.pem
 chmod 0640 /opt/vault/tls/vault-key.pem

 secret_result=$(gcloud secrets versions access latest --secret=TestCert --project=consul-vault)

 jq -r .vault_cert <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-cert.pem
 jq -r .vault_ca <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-ca.pem
 jq -r .vault_pk <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-key.pem
    
 cat <<- EOE > /etc/vault.d/vault.hcl
  disable_performance_standby = true
  ui = true
  disable_mlock = true
  storage "raft" {
    path    = "/opt/vault/data"
    node_id = "$(hostname -f)"
    retry_join {
      leader_api_addre        = "https://$(hostname -f):8200"
      leader_tls_servername   = "$(hostname -f)"
      leader_ca_cert_file     = "/opt/vault/tls/vault-ca.pem"
      leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
      leader_client_key_file  = "/opt/vault/tls/vault-key.pem"
      }
    }

cluster_addr = "https://$(hostname -f):8201"
api_addr = "https://$(hostname -f):8200"
      
listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_disable        = false
  tls_cert_file      = "/opt/vault/tls/vault-cert.pem"
  tls_key_file       = "/opt/vault/tls/vault-key.pem"
  tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
  }

EOE

chown root:root /etc/vault.d
chown root:vault /etc/vault.d/vault.hcl
chmod 640 /etc/vault.d/vault.hcl

systemctl enable vault
systemctl start vault

echo "Setup Vault profile"
cat << PROFILE | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR="https://$(hostname -f):8200"
export VAULT_CACERT="/opt/vault/tls/vault-ca.pem"
PROFILE
