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
.PHONY: clean clean-all clean-notice clean-pull clean-vault clean-keycloak clean-integrate pull vault-all vault-notice vault-setup keycloak-all keycloak-notice keycloak-setup integrate-all integrate-wait integrate-setup integrate-only testbed-all
ACTION ?= plan


################################
# CLEAN
################################
clean: #target ## Housekeeping

clean-all: clean-notice clean-integrate clean-keycloak clean-vault clean-pull #target ## **Clean All

clean-notice: #target ## Notice for Clean
	@echo "" && \
	echo "##############" && \
	echo "Cleaning up..." && \
	echo "##############" && \
	echo ""

clean-pull: #target ## Unlink Repos and Remove
	@rm -rf ./docker-vault && \
	rm -rf ./docker-keycloak && \
	rm -rf ./tmp

clean-vault: #target ## Clean Vault
	@cd docker-vault && \
	make -f Makefile clean-vault-all

clean-keycloak: #target ## Clean Keycloak
	@cd docker-keycloak && \
	make -f Makefile clean-keycloak-all

clean-integrate: #target ## Clean Integration
	@cd integration && \
	make -f Makefile clean-all && \
	cd ./terraform

################################
# SET UP DEPENDENCY REPOS
################################
pull: #target ## Pull Repos and Link
	@mkdir tmp && \
	cd tmp && \
	git clone https://github.com/F0otsh0T/hcp-vault-docker-enterprise.git && \
	git clone https://github.com/F0otsh0T/testbed-docker-keycloak.git && \
	cd .. && \
	ln -s ./tmp/hcp-vault-docker-enterprise/docker-vault ./docker-vault && \
	ln -s ./tmp/testbed-docker-keycloak/docker-keycloak ./docker-keycloak && \
	cp vault.hclic ./docker-vault/terraform/data/vault/shared/


################################
# SETUP AND RUN VAULT - PERSIST DATA WITH FILE VOLUME
# MAY NEED TO ENABLE FILE SHARING TO DOCKER VIA:
# DOCKER >> PREFERENCES >> RESOURCES >> FILE SHARING
################################
vault-all: vault-notice vault-setup #target ## All Setup Targets for Vault Services

vault-notice: #target ## Notice for Vault
	@echo "" && \
	echo "##################################################" && \
	echo "Spinning up Vault..." && \
	echo "Vault will be available at: https://localhost:8200" && \
	echo "##################################################" && \
	echo ""

vault-setup: #target ## Spin Up Vault Resources
	@cd docker-vault && \
	make -f Makefile vault-all


################################
# SETUP AND RUN KEYCLOAK - PERSIST DATA WITH FILE VOLUME
# MAY NEED TO ENABLE FILE SHARING TO DOCKER VIA:
# DOCKER >> PREFERENCES >> RESOURCES >> FILE SHARING
################################
keycloak-all: keycloak-notice keycloak-setup #target ## All Setup Targets for Keycloak Services

keycloak-notice: #target ## Notice for Keycloak
	@echo "" && \
	echo "#####################################################" && \
	echo "Spinning up Keycloak..." && \
	echo "Keycloak will be available at: https://localhost:8080" && \
	echo "#####################################################" && \
	echo ""

keycloak-setup: #target ## Spin Up Keycloak Resources
	@cd docker-keycloak && \
	make -f Makefile keycloak-all


################################
# INTEGRATION:
# INTEGRATE OIDC BETWEEN
# VAULT AND KEYCLOAK
################################
integrate-all: integrate-wait integrate-setup #target ## All Setup Targets for Integration

integrate-wait: #target ## Wait for Vault and Keycloak to be ready
	@echo "" && \
	echo "#############################################" && \
	echo "Waiting for Vault and Keycloak to be ready..." && \
	echo "#############################################" && \
	echo "" && \
	sleep 20

integrate-setup: #target ## Spin Up Integration Resources
	@cd integration && \
	make -f Makefile integrate-all

integrate-only: #target ## **Integrate Only - No Setup
	@cd integration && \
	make -f Makefile integrate


################################
# SETUP AND RUN TESTBED - PERSIST DATA WITH FILE VOLUME
# MAY NEED TO ENABLE FILE SHARING TO DOCKER VIA:
# DOCKER >> PREFERENCES >> RESOURCES >> FILE SHARING
################################
testbed-all: pull vault-all keycloak-all integrate-all #target ## **All Setup Targets for Testbed


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

