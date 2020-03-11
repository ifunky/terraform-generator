# Terraform Generator

This project allows you to create standard Terraform resources/accounts (ORG, RES or COR) and modules that have our best practice layouts.
The framework uses the popular Yeoman scafolding tool to generate Terraform projects that you can commit to your own source control system.

For more information on our cloud reference architectures and best practices see https://docs.ifunky.net

## Features

### Standard tooling
- Built using `PolyDev` containerised tooling - no need to install multiple tools locally (see useful links below)

### Create Terraform Modules
- Create modules with a base line structure
- Partially automated readme.md (just add title, description and how to use)
- Build badges for for popular CI servers such as CircleCI and GitLab
- Built in CI pipeline for basic Terraform validation

### Create AWS Landing Zone Accounts
- Create `organisation` master billing accounts
- Create `core` accounts that support the infrastructure and reduce blast radius
- Create `resource` repositories (for AWS accounts that support business workloads 


## Creating a new Terraform module
Navigate to the root of this repository and run the following commands:

    $ make polydev # This will drop you into the PolyDev tooling container shell
    $ make yo/module

Yeoman will prompt you for some questions in order to create a module with correct links to build badges etc.
```
Module name                     Enter the module name i.e. terraform-aws-ec2-instance
PolyDev Docker Image            Enter the the PolyDev image name. Defaults to ifunky/polydev:latest
Choose Source Control Provider  Select the name of your Git servive provider
Git Server URL Prefix           Enter the prefix (ending in a slash) of your git server i.e. https://github.com/ifunky/
Choose your CI server           Select your CI server from the list
```
#### Output
Currently the module will be output to the same directory.  Move it to an appropriate location and add it to your project.

## Creating a new Terraform resource account
Use this command if you'd like to create a new account of isolated Terraform resource repo:
   $ make yo/terraform

Yeoman will prompt you for the following:
```
Account name                   Enter a name using i.e. RES-ifunky
Account number                 Enter the account number i.e. 123445678
Repository Type                Select the type of repository to create
```

## Makefile Targets
The following targets are available: 

```
polydev                        Run docker locally to start developing with all the tools or run AWS CLI commands :-)
yo/module                      Run yeoman template generator to create a new Terraform module
yo/terraform                   Run yeoman template generator to create a new Terraform resource set (i.e. AWS account)
```