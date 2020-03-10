'use strict';
const Generator = require('yeoman-generator');
const yosay = require('yosay');

module.exports = class extends Generator {
  constructor(args, opts) {
    super(args, opts);
  }

  async prompting() {
    this.log(
      yosay('Welcome to the Terraform Repo Generator!')
    );

    this.answers = await this.prompt([
      {
        type: 'input',
        name: 'accountName',
        message: 'Enter the AWS account name : ',
      },
      {
        type: 'input',
        name: 'accountNumber',
        message: 'Enter the AWS account number : ',
      },
      {
        type: 'list',
        name: 'repoType',
        message: 'Choose repository type',
        choices: [{
            name: 'Resource Account/Products/Services',
            value: 'RES',
            checked: true
          },
          {
            name: 'Core Account',
            value: 'COR'
          },
          {
            name: 'Organisation (Master Acount)',
            value: 'ORG'
          },          
        ]
      },      
    ]);
  }

  writing() {
    this.destinationRoot(this.answers.repoType + "-" + this.answers.accountName);

    this.fs.copyTpl(
      `${this.templatePath()}/.!(gitignorefile|gitattributesfile)*`,
      this.destinationRoot(),
      this.props
    );

    this.fs.copy(
      this.templatePath('.gitlab-ci.yml'),
      this.destinationPath('.gitlab-ci.yml')
    );

    this.fs.copy(
      this.templatePath('.tflint.hcl'),
      this.destinationPath('.tflint.hcl')
    );

    this.fs.copy(
      this.templatePath('environment'),
      this.destinationPath('environment'), {
        accountNumber: this.answers.accountNumber.toLowerCase(),
      }
    );

    this.fs.copyTpl(
      this.templatePath('environment/_local_override.tfvars'),
      this.destinationPath('environment/_local_override.tfvars'), {
        accountNumber: this.answers.accountNumber.toLowerCase(),
      }
    );

    this.fs.copy(
      this.templatePath('scripts'),
      this.destinationPath('scripts')
    );

    this.fs.copy(
      this.templatePath('tests'),
      this.destinationPath('tests')
    );  

    this.fs.copy(
      this.templatePath('testresults'),
      this.destinationPath('testresults')
    );   
    
    this.fs.copyTpl(
      this.templatePath('Makefile'),
      this.destinationPath('Makefile'), {
        accountName: this.answers.accountName.toLowerCase(),
      }
    );

    this.fs.copyTpl(
      `${this.templatePath()}/**/*.tf`,
      this.destinationRoot()
    );

  }
};