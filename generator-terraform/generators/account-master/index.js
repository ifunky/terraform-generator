'use strict';
const Generator = require('yeoman-generator');
const yosay = require('yosay');

module.exports = class extends Generator {
  constructor(args, opts) {
    super(args, opts);
  }

  async prompting() {
    this.log(
      yosay('Welcome to the Terraform Master Account Generator!')
    );

    this.answers = await this.prompt([
      {
        type: 'input',
        name: 'companyName',
        message: 'Enter the company name or short code for it : ',
        validate: input => input.length > 0
      },
      {
        type: 'input',
        name: 'accountNumber',
        message: 'Enter your AWS account number : ',
        validate: input => input.length > 0
      },
      {
        type: 'input',
        name: 'repoName',
        message: 'Enter the full repository name : ',
        validate: input => input.length > 0,
        default: function(answers) {
          return `${answers.companyName}-org-master-account`;
        },
      },
      {
        type: 'input',
        name: 'region',
        message:
          'Enter the AWS region : ',
        default: 'eu-west-1',
        store: true
      },      
      {
        type: 'list',
        name: 'backend',
        message:
          'What state backend will you be using? (Full list of backends here: https://www.terraform.io/docs/backend/types/index.html) ',
          choices: [{
            name: 'AWS S3',
            value: 'S3'
          },
          {
            name: 'Hasicorp Consul',
            value: 'HC'
          },         
        ]
      },
      {
        when: props => props.backend === 'S3',
        type: 'input',
        name: 'stateBucketName',
        message: 'Name of the S3 Bucket for remote terraform state: ',
        default: function(answers) {
          return `${answers.companyName}-master-organisation-terraform`;
        },
        validate: input => input.length > 0
      },      
      {
        type: 'list',
        name: 'repoType',
        message: 'Choose repository type :',
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
    this.destinationRoot(this.answers.repoName);

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
        accountNumber: this.answers.accountNumber,
      }
    );

    this.fs.copyTpl(
      this.templatePath('environment/_local_override.tfvars'),
      this.destinationPath('environment/_local_override.tfvars'), {
        accountNumber: this.answers.accountNumber.toLowerCase(),
      }
    );

    this.fs.copyTpl(
      this.templatePath('environment/common.tfvars'),
      this.destinationPath('environment/common.tfvars'), {
        accountNumber: this.answers.accountNumber.toLowerCase(),
        companyName: this.answers.companyName.toLowerCase(), 
        stateBucketName: this.answers.stateBucketName, 
        region: this.answers.region, 
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
    
    this.fs.copyTpl(
      this.templatePath('Makefile'),
      this.destinationPath('Makefile')
    );

    this.fs.copyTpl(
      `${this.templatePath()}/**/*.tf`,
      this.destinationRoot()
    );

  }
};