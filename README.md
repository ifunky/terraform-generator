# Terraform Generator

This project allows you to create standard Terraform resources/accounts (ORG, RES or COR) and modules that have best practice layouts.
The framework uses the popular Yeoman scaffolding tool to generate Terraform projects that you can commit to your own source control system.

For more information on our cloud reference architectures and best practices see https://docs.ifunky.net

# Features

### Standard tooling
- Built using `PolyDev` containerised tooling - no need to install multiple tools locally (see useful links below)
- Uses iFunky Cloud Suite of Enterprise ready Terraform modules

### Create Terraform Modules
- Create modules with a baseline structure
- Partially automated readme.md (just add title, description and how to use)
- Build badges for for popular CI servers such as CircleCI and GitLab
- Built in CI pipeline for basic Terraform validation

### Create AWS Standalone Account

- Used for quick standalone AWS accounts (personal projects)

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
Choose Source Control Provider  Select the name of your Git service provider
Git Server URL Prefix           Enter the prefix (ending in a slash) of your git server i.e. https://github.com/ifunky/
Choose your CI server           Select your CI server from the list
```
#### Output
Currently the module will be output to the same directory.  Move it to an appropriate location and add it to your project.



# Creating Standalone Accounts

The Terraform Generator can be used to setup and configure AWS standalone accounts for those not wishing to implement the full Landing Zone Pattern.  This is useful for personal projects or isolated throw away environments.

Navigate to the root of this repository and run the following commands:

    $ make polydev # This will drop you into the PolyDev tooling container shell
    $ make yo/standalone

Yeoman will prompt you for some questions in order to create a module with correct links to build badges etc.



# Creating Landing Zone Accounts

Using the Terraform generator allows generic but opinionated root modules based on the concept of having a repo per account which allows access to infrastructure to be controlled using repository permissions.

### Create an Organisation Master Account

Use this command if you'd like to create a new account of isolated Terraform resource repo:

    $ make polydev # This will drop you into the PolyDev tooling container shell
    $ make yo/account-master

Follow the prompts to answer questions related to your organisation.  The resulting repo will be output into the same directory.  Check the settings and commit it to your server.


## Makefile Targets
The following targets are available: 

```
polydev                        Run docker locally to start developing with all the tools or run AWS CLI commands :-)
yo/module                      Run yeoman template generator to create a new Terraform module
yo/terraform                   Run yeoman template generator to create a new Terraform resource set (i.e. AWS account)
yo/standalone                  Run yeoman template generator to create a standalone AWS account with Terraform
```