'use strict';
const Generator = require('yeoman-generator');
const yosay = require('yosay');
var chalk = require('chalk');

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
        name: 'repoName',
        message: 'Enter the full repository name : ',
        validate: input => input.length > 0,
        default: function(answers) {
          return `${answers.companyName}-root-account`;
        },
      },
      {
        type: 'list',
        name: 'sourceControlType',
        message: 'Choose your source control provider :',
        store: true,
        choices: [{
            name: 'Github.com',
            value: 'GH'
          },
          {
            name: 'BitBucket.org',
            value: 'BB'
          },
          {
            name: 'GitLab Custom',
            value: 'GL'
          },          
        ]
      },
      {
        when: function(props) { return (/gh|gl|bb|/i).test(props.sourceControlType); },
        type: 'input',
        name: 'sourceControlPrefix',
        message: 'Enter your repo prefix i.e. https://gitserver.com/proj/group/ :',
        store: true,
        validate: input => input.length > 0
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
      },          
      {
        type: 'input',
        name: 'polydevDockerImage',
        message: 'Enter the PolyDev docker registry name : ',
        default: 'ifunky/polydev:latest',
        store: true,
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
        name: 'region',
        message:
          'Enter the AWS region : ',
        default: 'eu-west-1',
        store: true,
        validate: input => input.length > 0       
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
          return `${answers.companyName}-root-terraform`;
        },
        validate: input => input.length > 0
      },  
      {
        type: 'input',
        name: 'roleArn',
        message: 'Role arn of the service account used for S3: ',
        default: function(answers) {
          return `arn:aws:iam::${answers.accountNumber}:role/service-accounts/svc-terraform`;
        },
        validate: input => input.length > 0
      },  
      {
        type: 'input',
        name: 'roleArnTempAdmin',
        message: 'ARN of the manually created IAM user for initialising this account : ',
        default: function(answers) {
          return `arn:aws:iam::${answers.accountNumber}:role/temp-admin`;
        },
        validate: input => input.length > 0
      }  
    ]);
  }

  writing() {
    this.destinationRoot(this.answers.repoName);

    this.log(chalk.bold.yellow('Account:' + this.answers.accountNumber));
    this.log(chalk.bold.yellow('State:' + this.answers.stateBucketName));

    var gitCloneUrl = `${this.answers.sourceControlPrefix}${this.answers.repoName}.git`

    // Get build server urls
    var buildStatusUrl;
    var buildStatusImageUrl;

    switch(this.answers.ciServer) {
      case "CC":
        buildStatusUrl = `https://circleci.com/gh/ifunky/${this.answers.moduleName}`
        buildStatusImageUrl = buildStatusUrl + ".svg?style=svg"
        break;
      case "BB":
          buildStatusUrl = `${this.answers.sourceControlPrefix}/${this.answers.moduleName}/addon/pipelines/home#!/`
          buildStatusImageUrl = `${this.answers.sourceControlPrefix}/${this.answers.moduleName}/addon/pipelines/home#!/`
        break;  
      case "GL":
          buildStatusUrl = `${this.answers.sourceControlPrefix}/${this.answers.moduleName}//pipelines`
          buildStatusImageUrl = `${this.answers.sourceControlPrefix}/${this.answers.moduleName}/master/pipeline.svg`
        break;
    }

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
          polydevDockerImage: this.answers.polydevDockerImage,
          region: this.answers.region
        }
      );
    } 

    this.fs.copy(
      this.templatePath('.tflint.hcl'),
      this.destinationPath('.tflint.hcl')
    );

    this.fs.copyTpl(
      this.templatePath('environment'),
      this.destinationPath('environment'), {
        accountNumber: this.answers.accountNumber,
        region: this.answers.region,
        companyName: this.answers.companyName,
        stateBucketName: this.answers.stateBucketName,
        roleArn: this.answers.roleArn,
        roleArnTempAdmin: this.answers.roleArnTempAdmin
      }
    );

    this.log(chalk.bold.yellow('Account:' + this.answers.accountNumber));
    this.log(chalk.bold.yellow('State:' + this.answers.stateBucketName));

    this.fs.copy(
      this.templatePath('docs'),
      this.destinationPath('docs')
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
      this.templatePath('README.yaml'),
      this.destinationPath('README.yaml'), {
        repoName: this.answers.repoName.toLowerCase(),
        companyName: this.answers.companyName.toLowerCase(),         
        gitCloneUrl: gitCloneUrl,
        buildImageUrl: buildStatusUrl,
        buildStatusImageUrl: buildStatusImageUrl,
        sourceControlPrefix: this.answers.sourceControlPrefix
      }
    );

    this.fs.copyTpl(
      `${this.templatePath()}/**/*.tf`,
      this.destinationRoot(), {
        repoName: this.answers.repoName.toLowerCase(),
        companyName: this.answers.companyName.toLowerCase(),         
        gitCloneUrl: gitCloneUrl,
        buildImageUrl: buildStatusUrl,
        buildStatusImageUrl: buildStatusImageUrl,
        region: this.answers.region,
        sourceControlPrefix: this.answers.sourceControlPrefix
      }
    );

  }
};