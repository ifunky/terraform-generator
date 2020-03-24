.SHELL := /usr/bin/bash
export TF_IN_AUTOMATION = 1
export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

METADATA_DOCS_FILE := "docs/metadata.md"
TARGETS_DOCS_FILE  := "docs/targets.md"

#  Default to dev if environment not set
WORKSPACE=${TERRAFORM_ENV}
ifeq ($(WORKSPACE),)
WORKSPACE := "dev"
endif

# Extract the AWS region from the specified environment or common if not found
AWS_REGION=${shell awk -F "=" '/region/ {print $$2}' environment/$(WORKSPACE).tfvars}
ifeq ($(AWS_REGION),)
	AWS_REGION := ${shell awk -F "=" '/region/ {print $$2}' environment/common.tfvars}
endif

# Setup environment using convention from current directory name.
AWS_PROFILE="$(shell basename "$$PWD")-$(WORKSPACE)"
ENVIRONMENT_OVERRIDE_FILE=env_override.tfvars

define polydev
	@docker run -it \
		--env AWS_DEFAULT_REGION="$(AWS_REGION)" \
		--user "$$(id -u):$$(id -g)" \
		-v "$$PWD:/data" \
		ifunky/polydev:latest $1
endef

# Set special local override varible file if it exists
LOCAL_OVERRIDE-FiLE=environment/_local_override.tfvars
ifneq ("$(wildcard $(LOCAL_OVERRIDE-FiLE))","")
	LOCAL_OVERRIDE=-var-file="$(LOCAL_OVERRIDE-FiLE)"
	BACKEND_OVERRIDE=-backend-config="$(LOCAL_OVERRIDE-FiLE)"
endif

#####################################################################
# Private targets designed to be run within the PolyDev shell	
#####################################################################
help:
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

help/private:
	@grep -E '^[a-zA-Z_-_\/]+:.?#- .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?#- "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dockerpull: ## Pull latest version of docker image polydev
	@docker pull ifunky/polydev

apply: prep ## Apply Terraform changes
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		tfplan_$(WORKSPACE)

prep: #- Internal usage for checking required variables have been set
	@if [ -z "${TERRAFORM_ENV}" ]; then \
       echo "TERRAFORM_ENV' is not set but by default this will be set to 'dev', this is used for selecting the correct environment/TERRAFORM_ENV.tfvars file.\nFor example: export TERRAFORM_ENV=dev\n";\
	   read -p "Please confirm you ok with the above settings?" pressenter;\
	fi\

clean: ## Clean Terraform specific state folders
	@rm -rf .terraform *.tfstate terraform.tfstate.d tfplan *.plan

createdocs/targets: # Create list of make targets in Markdown format
	@echo Auto creating README.md....
	@rm -rf $(TARGETS_DOCS_FILE)
	@echo "## Makefile Targets" >> $(TARGETS_DOCS_FILE)
	@echo -e "The following targets are available: \n" >> $(TARGETS_DOCS_FILE)
	@echo '```' >> $(TARGETS_DOCS_FILE)
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\%-30s\ %s\n", $$1, $$2}' >> $(TARGETS_DOCS_FILE)
	@echo '```' >> $(TARGETS_DOCS_FILE)

createdocs: createdocs/targets # Auto create README.md documentaion
	@terraform-config-inspect > $(METADATA_DOCS_FILE)
	@sed -i -e '1,2d' $(METADATA_DOCS_FILE)   				# Remove first line as not needed
	@sed -i '1i# Module Specifics' $(METADATA_DOCS_FILE)	# Add title to first line
	@gomplate --file ./docs/README.md.template \
	--out README.md

destroy: prep ## CAUTION!!  THIS WILL  DESTROY EVERYTHING (WITH PROMPT!)
	@terraform destroy \
	-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

polydev: prep dockerpull ## Run docker locally to start developing with all the tools or run AWS CLI commands :-)
	@aws-vault exec --duration 1h $(AWS_PROFILE) -- \
	docker run -it \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	-e AWS_SECURITY_TOKEN \
	--env AWS_DEFAULT_REGION=eu-west-1 \
	--env TERRAFORM_ENV=${WORKSPACE} \
	--user "$$(id -u):$$(id -g)" \
	-v "$$PWD:/data" \
	ifunky/polydev:latest

init-env-vars: ## Make a list of Terraform override variables
	@echo '--------------------------------------------------------------------------------------------------------------------------------------------------------'
	@echo 'Creating Terraform override vars file from any environment varibles (TF_VAR_).  These will override everything else (opposite to Terraform default)'
	@printenv | grep TF_VAR_ > $(ENVIRONMENT_OVERRIDE_FILE) || true
	@sed -i -e 's/TF_VAR_//g' $(ENVIRONMENT_OVERRIDE_FILE)				# Remove TF_VAR_
	@sed -i -e 's/=/="/g'  -e 's/$$/"/' $(ENVIRONMENT_OVERRIDE_FILE)	# Add quotes around varible value
	@echo
	@echo 'Environment override variables:'
	@cat $(ENVIRONMENT_OVERRIDE_FILE)
	@echo '--------------------------------------------------------------------------------------------------------------------------------------------------------'

init-proj: prep clean init-env-vars ## Intialise a new AWS account including S3 terraform state bucket and removal of default VPCs in ALL regions
	@echo Removing default VPCs
	@source ./scripts/assume_role.sh $$TF_VAR_role_arn ;\
	aws sts get-caller-identity; \
	export HOME=$(shell pwd); \
	./scripts/aws-delete-default-vpc.sh
	@echo '' > backend.tf
	@terraform get -update 
	@terraform init -backend=false -var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE) -var-file="$(ENVIRONMENT_OVERRIDE_FILE)" 
	@terraform plan -out=backend.plan -target=module.account -target=module.backend -target=module.vpc -var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE) -var-file="$(ENVIRONMENT_OVERRIDE_FILE)" 
	@terraform apply backend.plan
	@echo -e 'terraform { \n backend "s3" { \n\t # Partial configuration is used since variables are not allowed. \n\t} \n}' > backend.tf
	@echo "yes" | TF_INPUT="true" terraform init -reconfigure -force-copy -backend-config="environment/common.tfvars" -backend-config="environment/$(WORKSPACE).tfvars" $(BACKEND_OVERRIDE) -backend-config="$(ENVIRONMENT_OVERRIDE_FILE)"
	@rm -f backend.plan $(ENVIRONMENT_OVERRIDE_FILE)

init-proj-destroy: prep init-env-vars ## Destroy only resources created by the init-proj target
	@terraform destroy -target=module.account -target=module.backend -target=module.vpc \
	-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

init: prep ## Initialise the project
	@terraform init \
	-reconfigure \
	-backend-config="environment/common.tfvars" -backend-config="environment/$(WORKSPACE).tfvars" $(BACKEND_OVERRIDE) \
	-input=false \
	-lock=true  

validate: prep ## Validate Terraform code 
	@echo Running validation on Terraform code....
	@terraform validate \
	-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)
	@echo Running lint checks on Terraform code....	
	@tflint --var-file="environment/common.tfvars" --var-file="environment/$(WORKSPACE).tfvars" --aws-region=eu-west-1

scan: ## Run Terraform static code analysis
	@tfsec .

test-infra:  ## Run Inspec infrastrucuture tests in the context of the `role_arn`
	@terraform output --json > tests/aws-infrastructure/files/terraform.json
	@echo Set HOME environment varible to current folder otherwise inspec runs from the root   
	@source ./scripts/assume_role.sh ${shell awk -F "=" '/\<role_arn\>/ {print $$2}' environment/$(WORKSPACE).tfvars} ;\
	aws sts get-caller-identity; \
	export HOME=$(shell pwd); \
	inspec exec tests/cis-aws-foundations-baseline -t aws:// --input-file=tests/attributes.yml --reporter cli junit:testresults/aws_security.xml

plan: prep validate ## Show what terraform thinks it will do
	@date
	@terraform workspace list
	@terraform get -update 
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-out tfplan_$(WORKSPACE) \
		-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

refresh: ## Refresh the state (useful after adding new `outputs`)
	@terraform refresh \
		-lock=true \
		-input=false \
		-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

#####################################################################
# Public targets designed to be run directly from the command line
#####################################################################

polydev/createdocs: prep ## Run PolyDev createdocs directly from your shell
	$(call polydev,make createdocs)

polydev/validate: prep ## Validate using PolyDev
	$(call polydev,make validate)