.SHELL := /usr/bin/bash

define yo
	@echo Set HOME environment variable to current folder otherwise yeoman runs from the root and blows up
	@export HOME=$(shell pwd);npm install generator-terraform; \
	yo ./generator-terraform/generators/$1/index.js --local-only # terraform:$1
endef

help: 
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

polydev: ## Run docker locally to start developing with all the tools or run AWS CLI commands :-)
	@docker run -it \
	--env AWS_DEFAULT_REGION="eu-west-1" \
	--user "$$(id -u):$$(id -g)" \
	-v "$$PWD:/data" \
	ifunky/polydev:latest

yo/module: ## Run yeoman template generator to create a new Terraform module
	$(call yo,module)

yo/terraform: ## Run yeoman template generator to create a new Terraform resource set (i.e. AWS account)
	$(call yo,terraform)
