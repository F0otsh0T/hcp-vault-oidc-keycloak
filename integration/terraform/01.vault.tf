# 01.vault.tf

################################################
# VAULT NAMESPACES

resource "vault_namespace" "demo" {
  path = "demo"
}


################################################
# VAULT SECRETS ENGINE: KVv2
# NAMESPACE: demo

resource "vault_mount" "kvv2" {
  namespace   = vault_namespace.demo.path
  type        = "kv"
  description = "KVv2 Secret Engine Mount"
  options     = { version = "2" }
  path        = "secret"
}

resource "vault_kv_secret_v2" "app1_secret" {
  namespace           = vault_namespace.demo.path
  mount               = vault_mount.kvv2.path
  name                = "app1"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap1",
      foo = "bar1"
    }
  )
}

resource "vault_kv_secret_v2" "app2_secret" {
  namespace           = vault_namespace.demo.path
  mount               = vault_mount.kvv2.path
  name                = "app2"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap2",
      foo = "bar2"
    }
  )
}


################################################
# VAULT AUTH: OIDC
# NAMESPACE: root

resource "vault_identity_oidc_key" "keycloak_provider_key_root" {
  name      = "keycloak"
  algorithm = "RS256"
}

resource "vault_jwt_auth_backend" "keycloak_root" {
  path         = "oidc"
  type         = "oidc"
  default_role = "default"
  #  oidc_discovery_url = format("http://keycloak:8080/realms/%s", keycloak_realm.demo.id)
  oidc_discovery_url = format("${var.keycloak_url}/realms/%s", keycloak_realm.demo.id)
  oidc_client_id     = keycloak_openid_client.openid_client.client_id
  oidc_client_secret = keycloak_openid_client.openid_client.client_secret
  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default_root" {
  backend         = vault_jwt_auth_backend.keycloak_root.path
  role_name       = "default"
  token_ttl       = 3600
  token_max_ttl   = 3600
  token_policies  = ["default"]
  bound_audiences = [keycloak_openid_client.openid_client.client_id]
  user_claim      = "email"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }
  role_type             = "oidc"
  allowed_redirect_uris = [
    "${var.vault_url}/ui/vault/auth/oidc/oidc/callback",
    "http://127.0.0.1:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  groups_claim          = format("/resource_access/%s/roles", keycloak_openid_client.openid_client.client_id)
}


################################################
# VAULT AUTH: OIDC
# NAMESPACE: demo

resource "vault_identity_oidc_key" "keycloak_provider_key_demo" {
  namespace  = vault_namespace.demo.path
  name       = "keycloak"
  algorithm  = "RS256"
}

# resource "vault_jwt_auth_backend" "keycloak_demo" {
#   namespace          = vault_namespace.demo.path
#   path               = "oidc"
#   type               = "oidc"
#   default_role       = "default"
#   # oidc_discovery_url = format("http://keycloak:8080/realms/%s", keycloak_realm.demo.id)
#   oidc_discovery_url = format("http://${var.keycloak_url}/realms/%s", keycloak_realm.demo.id)
#   oidc_client_id     = keycloak_openid_client.openid_client.client_id
#   oidc_client_secret = keycloak_openid_client.openid_client.client_secret
#   tune {
#     audit_non_hmac_request_keys  = []
#     audit_non_hmac_response_keys = []
#     default_lease_ttl            = "1h"
#     listing_visibility           = "unauth"
#     max_lease_ttl                = "1h"
#     passthrough_request_headers  = []
#     token_type                   = "default-service"
#   }
# }

resource "vault_jwt_auth_backend" "keycloak_demo" {
  namespace          = vault_namespace.demo.path
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  # oidc_discovery_url = format("http://keycloak:8080/realms/%s", keycloak_realm.demo.id)
  oidc_discovery_url = format("${var.keycloak_url}/realms/%s", keycloak_realm.demo.id)
  oidc_client_id     = keycloak_openid_client.openid_client.client_id
  oidc_client_secret = keycloak_openid_client.openid_client.client_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default_demo" {
  namespace       = vault_namespace.demo.path
  backend         = vault_jwt_auth_backend.keycloak_demo.path
  role_name       = "default"
  token_ttl       = 3600
  token_max_ttl   = 3600
  token_policies  = ["default"]
  bound_audiences = [keycloak_openid_client.openid_client.client_id]
  user_claim      = "email"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }
  role_type             = "oidc"
  allowed_redirect_uris = [
    "${var.vault_url}/ui/vault/auth/oidc/oidc/callback",
    "http://127.0.0.1:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  groups_claim          = format("/resource_access/%s/roles", keycloak_openid_client.openid_client.client_id)
}


################################################
# VAULT POLICIES

resource "vault_policy" "vault_super_admin" {
  name   = "vault-super-admin"
  policy = templatefile("${path.module}/templates/vault_super_admin_policy.tpl", {})
}

resource "vault_policy" "vault_admin" {
  namespace = vault_namespace.demo.path
  name   = "vault-admin"
  policy = templatefile("${path.module}/templates/vault_admin_policy.tpl", {})
}

resource "vault_policy" "app1_owner" {
  namespace = vault_namespace.demo.path
  name   = "app1-owner"
  policy = templatefile("${path.module}/templates/app1_owner_policy.tpl", {})
}

resource "vault_policy" "app1_reader" {
  namespace = vault_namespace.demo.path
  name   = "app1-reader"
  policy = templatefile("${path.module}/templates/app1_reader_policy.tpl", {})
}

resource "vault_policy" "app2_owner" {
  namespace = vault_namespace.demo.path
  name   = "app2-owner"
  policy = templatefile("${path.module}/templates/app2_owner_policy.tpl", {})
}

resource "vault_policy" "app2_reader" {
  namespace = vault_namespace.demo.path
  name   = "app2-reader"
  policy = templatefile("${path.module}/templates/app2_reader_policy.tpl", {})
}


################################################
# VAULT GROUPS - EXTERNAL
# NAMESPACE: root

resource "vault_identity_group" "vault_super_admin_group" {
  name      = "vault-super-admin"
  type      = "external"
  policies = [
    vault_policy.vault_super_admin.name
  ]
}

resource "vault_identity_group_alias" "vault_super_admin_group_alias" {
  name           = "vault-super-admin"
  mount_accessor = vault_jwt_auth_backend.keycloak_root.accessor
  canonical_id   = vault_identity_group.vault_super_admin_group.id
}


################################################
# VAULT GROUPS - EXTERNAL
# NAMESPACE: demo

resource "vault_identity_group" "vault_admin_group" {
  name      = "vault-admin"
  namespace = vault_namespace.demo.path
  type      = "external"
  policies = [
    vault_policy.vault_admin.name
  ]
}

resource "vault_identity_group_alias" "vault_admin_group_alias" {
  name           = "vault-admin"
  namespace      = vault_namespace.demo.path
  mount_accessor = vault_jwt_auth_backend.keycloak_demo.accessor
  canonical_id   = vault_identity_group.vault_admin_group.id
}

resource "vault_identity_group" "app1_owner_group" {
  name      = "app1-owner"
  namespace = vault_namespace.demo.path
  type      = "external"
  metadata = {
    app-name = "app1"
  }
  policies = [
    vault_policy.app1_owner.name
  ]
}

resource "vault_identity_group_alias" "app1_owner_group_alias" {
  name           = "app1-owner"
  namespace      = vault_namespace.demo.path
  mount_accessor = vault_jwt_auth_backend.keycloak_demo.accessor
  canonical_id   = vault_identity_group.app1_owner_group.id
}

resource "vault_identity_group" "app2_owner_group" {
  name      = "app2-owner"
  namespace = vault_namespace.demo.path
  type      = "external"
  metadata = {
    app-name = "app2"
  }
  policies = [
    vault_policy.app2_owner.name
  ]
}

resource "vault_identity_group_alias" "app2_owner_group_alias" {
  name           = "app2-owner"
  namespace      = vault_namespace.demo.path
  mount_accessor = vault_jwt_auth_backend.keycloak_demo.accessor
  canonical_id   = vault_identity_group.app2_owner_group.id
}


################################################
# VAULT AUTH: APPROLE
# NAMESPACE: demo

resource "vault_auth_backend" "approle" {
  namespace = vault_namespace.demo.path
  type      = "approle"
}

resource "vault_approle_auth_backend_role" "app1" {
  namespace      = vault_namespace.demo.path
  backend        = vault_auth_backend.approle.path
  role_name      = "app1"
  token_policies = ["app1-reader"]
}

data "vault_approle_auth_backend_role_id" "app1" {
  namespace = vault_namespace.demo.path
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.app1.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "app1" {
  depends_on = [
    vault_approle_auth_backend_role.app1 #,
  ]
  namespace    = vault_namespace.demo.path
  backend      = vault_auth_backend.approle.path
  role_name    = vault_approle_auth_backend_role.app1.role_name
  wrapping_ttl = "5m"
}

################################################
# VAULT AGENT: RENDER SECRET TO FILE

# resource "local_file" "approle_id" {
#   content  = data.vault_approle_auth_backend_role_id.app1.role_id
#   filename = "../docker-compose/vault-agent/app1_role_id"
# }

# resource "local_file" "approle_secret" {
#   content  = vault_approle_auth_backend_role_secret_id.app1.wrapping_token
#   filename = "../docker-compose/vault-agent/app1_secret_id"
# }










