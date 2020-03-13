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
        name: 'companyName',
        message: 'Enter the company name or short code for it : ',
        validate: input => input.length > 0
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
      {
        type: 'list',
        name: 'ciServer',
        message: 'Choose your CI build server',
        choices: [{
            name: 'GitLab',
            value: 'GL',
            checked: true
          },
          {
            name: 'BitBucket.org Pipelines',
            value: 'BB'
          },
          {
            name: 'CircleCI',
            value: 'CC'
          },          
        ]
      }              
    ]);
  }

  writing() {
    this.destinationRoot(this.answers.repoType;

    this.fs.copyTpl(
      `${this.templatePath()}/.!(gitignorefile|gitattributesfile)*`,
      this.destinationRoot(),
      this.props
    );

    // Copy appropriate CI build file
    if (this.answers.sourceControlType == 'GL') {
      this.fs.copyTpl(
        this.templatePath('.gitlab-ci.yml'),
        this.destinationPath('.gitlab-ci.yml'), {
          polydevDockerImage: this.answers.polydevDockerImage
        }
      );
    } else if (this.answers.sourceControlType == 'CC') {
      this.fs.copy(
        this.templatePath('.circleci'),
        this.destinationPath('.circleci')
      );
      this.fs.copyTpl(
        this.templatePath('.circleci/config.yml'),
        this.destinationPath('.circleci/config.yml'), {
          polydevDockerImage: this.answers.polydevDockerImage
        }
      );      
    } else if (this.answers.sourceControlType == 'BB') {
      this.fs.copyTpl(
        this.templatePath('bitbucket-pipelines.yml'),
        this.destinationPath('bitbucket-pipelines.yml'), {
          polydevDockerImage: this.answers.polydevDockerImage
        }
      );
    } 

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