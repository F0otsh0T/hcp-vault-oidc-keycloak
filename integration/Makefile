################################################################################
# MAKEFILE
#
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - 
#   - 
################################################################################

################################
# FOUNDATION
################################
default: help
.PHONY: clean clean-all clean-integrate integrate-all integrate-input integrate test
ACTION ?= plan
VAULT_INIT_OUTPUT ?= ../docker-vault/terraform/data/scripts/vault.json
KEYCLOAK_ADMIN_USER ?= admin
KEYCLOAK_ADMIN_PASSWORD ?= passw0rd

test: #target ## Test


################################
# CLEAN
################################
clean: #target ## Housekeeping

clean-all: clean-integrate #target ## Clean All

clean-integrate: #target ## Clean Integration
	@terraform -chdir=./terraform init && \
	terraform -chdir=./terraform destroy -auto-approve



################################
# INTEGRATE VAULT AND KEYCLOAK
################################
integrate-all: integrate-input integrate #target ## Integrate All Vault and Keycloak

# Not needed if manually editing ./terraform/terraform.auto.tfvars
integrate-input: #target ## Harvest Inputs from Docker Vault and Keycloak
	@echo "vault_root_token = \"$$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')\"" > ./terraform/terraform.auto.tfvars
	@echo "keycloak_user = \"$(KEYCLOAK_ADMIN_USER)\"" >> ./terraform/terraform.auto.tfvars
	@echo "keycloak_password = \"$(KEYCLOAK_ADMIN_PASSWORD)\"" >> ./terraform/terraform.auto.tfvars
	@cat ./terraform/terraform.auto.tfvars

integrate: #target ## Integrate Vault and Keycloak
	@terraform -chdir=./terraform init -upgrade && \
	terraform -chdir=./terraform apply -auto-approve


################################
# HELP
# REF GH @ jen20/hashidays-nyc/blob/master/terraform/GNUmakefile
########################
.PHONY: help
help: #target ## Display help for this Makefile (default target).
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check_defined = \
		$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))

