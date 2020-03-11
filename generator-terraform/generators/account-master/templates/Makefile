.SHELL := /usr/bin/bash
export TF_IN_AUTOMATION = 1
export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

METADATA_DOCS_FILE := "docs/metadata.md"
TARGETS_DOCS_FILE  := "docs/targets.md"
WORKSPACE="${TERRAFORM_ENV}"

define polydev
	@docker run -it \
		--env AWS_DEFAULT_REGION="eu-west-1" \
		--user "$$(id -u):$$(id -g)" \
		-v "$$PWD:/data" \
		ifunky/polydev:latest $1
endef

ACCOUNT_NAME=$(shell basename "$$PWD" | tr '[:upper:]' '[:lower:]' | cut -d "-" -f2)

# Set special local override varible file file if it exists
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

dockerpull: ## Pulls the latest version of polydev docker image
	@docker pull ifunky/polydev

apply: prep ## Apply Terraform changes
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		tfplan

prep: #- Internal usage for checking required variables have been set
	@if [ -z "${TERRAFORM_ENV}" ]; then\
    echo "TERRAFORM_ENV' is not set, this is used for selecting the correct environment/TERRAFORM_ENV.tfvars";\
	exit 1;\
	fi\

clean: ## Clean Terraform specific state folders
	@rm -rf .terraform
	@rm -rf terraform.tfstate.d
	@rm -rf tfplan

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

polydev: dockerpull ## Run docker locally to start developing with all the tools or run AWS CLI commands :-)
	@aws-vault exec --assume-role-ttl 1h $(ACCOUNT_NAME)-adm -- \
	docker run -it \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	-e AWS_SECURITY_TOKEN \
	--env AWS_DEFAULT_REGION="eu-west-1" \
	--env TERRAFORM_ENV=dev \
	--user "$$(id -u):$$(id -g)" \
	-v "$$PWD:/data" \
	ifunky/polydev:latest

init-proj: prep clean ## Intialise a new AWS account including S3 terraform state bucket and removal of default VPCs in ALL regions
	@echo Removing default VPC
	@./scripts/aws-delete-default-vpc.sh
	@echo '' > backend.tf
	@terraform get -update 
	@terraform init -backend=false -var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)
	@terraform plan -out=backend.plan -target=module.account -target=module.backend -var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE) 
	@terraform apply backend.plan
	@echo -e 'terraform { \n backend "s3" { \n\t # Partial configuration is used since variables are not allowed. \n\t} \n}' > backend.tf
	@echo "yes" | TF_INPUT="true" terraform init -reconfigure -force-copy -backend-config="environment/common.tfvars" -backend-config="environment/$(WORKSPACE).tfvars" $(BACKEND_OVERRIDE)
	@rm -f backend.plan

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
	@tflint --var-file="environment/common.tfvars" --var-file="environment/$(WORKSPACE).tfvars"

scan: ## Run Terraform static code analysis
	@tfsec .

test-infra:  ## Run Inspec infrastrucuture tests in the context of the `terraform_role_arn`
	@echo Set HOME environment varible to current folder otherwise inspec runs from the root   
	@source ./scripts/assume_role.sh ${shell awk -F "=" '/terraform_role_arn/ {print $$2}' environment/common.tfvars} ;\
	aws sts get-caller-identity; \
	export HOME=$(shell pwd); \
	inspec exec tests/cis-aws-foundations-baseline -t aws:// --attrs=tests/attributes.yml --reporter cli junit:testresults/aws_security.xml
	#inspec exec tests/aws-security -t aws:// --reporter cli junit:testresults/aws_security.xml
	
	#REPORT=$$(inspec exec tests/aws-security -t aws:// --reporter cli); \
	#echo "DAN: $(REPORT)"  #junit:$(shell pwd)/testresults/aws_security.xml

plan: validate ## Show what terraform thinks it will do
	@date
	@terraform workspace list
	@terraform get -update 
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-out tfplan \
		-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

refresh: ## Refresh the state (useful after adding new `outputs`)
	@terraform refresh \
		-lock=true \
		-input=false \
		-var-file="environment/common.tfvars" -var-file="environment/$(WORKSPACE).tfvars" $(LOCAL_OVERRIDE)

#####################################################################
# Public targets designed to be run directly from the command line
#####################################################################

polydev/createdocs: ## Run PolyDev createdocs directly from your shell
	$(call polydev,make createdocs)