# Terraform Generator

This project allows you to create standard Terraform resources/accounts (ORG, RES or COR) and modules that have our best practice layouts.
The framework uses the popular Yeoman scafolding tool to generate Terraform projects that you can commit to your own source control system.

For more information on our reference architectures and best practices see https://docs.ifunky.net

## Features

### Create Core Repos
- Create 


### Create Resources Repos
- Create resource type structures (for AWS accounts or separate isolated pieces of infrastructure)

### Create Terraform Modules
- Create modules with a base line structure
- Tests included

## Creating a new Terraform module
Navigate to the root of this repository and run the following command:
   $ make yo/module

Yeoman will prompt you for the name of your module. 

## Creating a new Terraform resource account
Use this command if you'd like to create a new account of isolated Terraform resource repo:
   $ make yo/terraform

Yeoman will prompt you for the following:
```
Account name                   Enter a name using i.e. RES-ifunky
Account number                 Enter the account number i.e. 123445678
Repository Type                Select the type of repository to create
```

## Creating a new Terraform resource for a Client
Use this command if you'd like to create a new resource project for a client.
   $ make yo/resource-client

Yeoman will prompt you for the following:
```
Account name                   Enter a name using i.e. FwDevTest
Account number                 Enter the account number i.e. 123445678 (for the development environment)

```

## Makefile Targets
The following targets are available: 

```
polydev                        Run docker locally to start developing with all the tools or run AWS CLI commands :-)
yo/module                      Run yeoman template generator to create a new Terraform module
yo/terraform                   Run yeoman template generator to create a new Terraform resource set (i.e. AWS account)
```