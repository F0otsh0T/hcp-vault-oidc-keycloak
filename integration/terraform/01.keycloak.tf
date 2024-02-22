# 0.keycloak.tf

################################################
# KEYCLOAK REALM: demo

resource "keycloak_realm" "demo" {
  realm   = "demo"
  enabled = true
}


################################################
# KEYCLOAK OPENID CLIENT FOR VAULT

resource "keycloak_openid_client" "openid_client" {
  realm_id              = keycloak_realm.demo.id
  client_id             = "vault"
  name                  = "vault"
  description           = "Vault OIDC Client"
  access_type           = "CONFIDENTIAL"
  enabled               = true
  standard_flow_enabled = true
  valid_redirect_uris = [
    "${var.vault_url}/*",
    "http://127.0.0.1:8200/*",
    "http://localhost:8200/*",
    "http://localhost:8250/*"
  ]
  login_theme = "keycloak"
  #   client_template         = "oidc"
  #   protocol                = "openid-connect"
  #   default_client_scopes   = ["openid", "profile", "email", "roles"]
  #   root_url                = "http://localhost:8200"
  #   redirect_uris           = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  #   web_origins             = ["http://localhost:8200"]
  #   optional_client_scopes  = ["address", "phone", "offline_access"]
  #   service_account_user_id = "vault"
  #   service_account_roles   = ["vault-super-admin", "vault-admin"]
}

resource "keycloak_openid_user_client_role_protocol_mapper" "user_client_role_mapper" {
  realm_id    = keycloak_realm.demo.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "user-client-role-mapper"
  claim_name  = format("resource_access.%s.roles", keycloak_openid_client.openid_client.client_id)
  multivalued = true
  #   protocol        = "openid-connect"
  #   protocol_mapper = "user-client-role-mapper"
  #   config = {
  #     "id.token.claim" = "true"
  #     "access.token.claim" = "true"
  #     "claim.name" = "roles"
  #     "jsonType.label" = "String"
  #     "multivalued" = "true"
  #     "userinfo.token.claim" = "true"
  #     "claim.value" = "roles"
  #   }
}


################################################
# KEYCLOAK USERS: ALICE, BOB, CAROL, DAN

resource "keycloak_user" "user_alice" {
  realm_id = keycloak_realm.demo.id
  username = "alice"
  enabled  = true

  email      = "alice@yoyodyne.com"
  first_name = "Alice"
  last_name  = "Yaya"

  initial_password {
    value     = "alice"
    temporary = false
  }
}

resource "keycloak_user" "user_bob" {
  realm_id = keycloak_realm.demo.id
  username = "bob"
  enabled  = true

  email      = "bob@yoyodyne.com"
  first_name = "Bob"
  last_name  = "Bigboote"

  initial_password {
    value     = "bob"
    temporary = false
  }
}

resource "keycloak_user" "user_carol" {
  realm_id = keycloak_realm.demo.id
  username = "carol"
  enabled  = true

  email      = "carol@yoyodyne.com"
  first_name = "Carol"
  last_name  = "Kimchi"

  initial_password {
    value     = "carol"
    temporary = false
  }
}

resource "keycloak_user" "user_dan" {
  realm_id = keycloak_realm.demo.id
  username = "dan"
  enabled  = true

  email      = "dan@yoyodyne.com"
  first_name = "Dan"
  last_name  = "Smallberries"

  initial_password {
    value     = "dan"
    temporary = false
  }
}


################################################
# KEYCLOAK USER ROLES: ALICE, BOB, CAROL, DAN

resource "keycloak_user_roles" "alice_roles" {
  realm_id = keycloak_realm.demo.id
  user_id  = keycloak_user.user_alice.id

  role_ids = [
    keycloak_role.vault_super_admin_role.id
  ]
}

resource "keycloak_user_roles" "bob_roles" {
  realm_id = keycloak_realm.demo.id
  user_id  = keycloak_user.user_bob.id

  role_ids = [
    keycloak_role.vault_admin_role.id
  ]
}

resource "keycloak_user_roles" "carol_roles" {
  realm_id = keycloak_realm.demo.id
  user_id  = keycloak_user.user_carol.id

  role_ids = [
    keycloak_role.app1_owner_role.id
  ]
}

resource "keycloak_user_roles" "dan_roles" {
  realm_id = keycloak_realm.demo.id
  user_id  = keycloak_user.user_dan.id

  role_ids = [
    keycloak_role.app2_owner_role.id
  ]
}


################################################
# KEYCLOAK ROLES: 
# - vault-super-admin
# - vault-admin
# - app1-owner
# - app2-owner

resource "keycloak_role" "vault_super_admin_role" {
  realm_id    = keycloak_realm.demo.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "vault-super-admin"
  description = "Vault Super Admin Role"
}

resource "keycloak_role" "vault_admin_role" {
  realm_id    = keycloak_realm.demo.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "vault-admin"
  description = "Vault Admin Role"
}

resource "keycloak_role" "app1_owner_role" {
  realm_id    = keycloak_realm.demo.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "app1-owner"
  description = "App1 Owner Role"
}

resource "keycloak_role" "app2_owner_role" {
  realm_id    = keycloak_realm.demo.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "app2-owner"
  description = "App2 Owner Role"
}




