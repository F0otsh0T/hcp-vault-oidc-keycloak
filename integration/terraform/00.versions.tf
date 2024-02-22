# 00.versions.tf

terraform {
  required_version = ">= 0.13"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 3.0.0"
    }
  }
}

locals {
  vault_root_token  = var.vault_root_token
  keycloak_user     = var.keycloak_user
  keycloak_password = var.keycloak_password
}

provider "vault" {
  address = var.vault_url
  token   = local.vault_root_token
}

provider "keycloak" {
  url       = var.keycloak_url
  client_id = "admin-cli"
  username  = local.keycloak_user
  password  = local.keycloak_password
  base_path = ""
}




