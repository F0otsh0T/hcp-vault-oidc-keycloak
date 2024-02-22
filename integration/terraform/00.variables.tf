# 00.variables.tf

# variable "" {
#     type = string
#     description = ""
#     sensitive = false
#     default = ""
# }

################################################
# VAULT VARIABLES

variable "vault_root_token" {
  type        = string
  description = "Vault Root Token"
  sensitive   = false
  default     = ""
}

variable "vault_url" {
  type        = string
  description = "Vault URL"
  sensitive   = false
  default     = "http://localhost:8200"
}







################################################
# KEYCLOAK VARIABLES

variable "keycloak_user" {
  type        = string
  description = "Keycloak User"
  sensitive   = false
  default     = ""
}

variable "keycloak_password" {
  type        = string
  description = "Keycloak Password"
  sensitive   = false
  default     = ""
}

variable "keycloak_url" {
  type        = string
  description = "Keycloak URL"
  sensitive   = false
  default     = "http://keycloak:8080"
}





