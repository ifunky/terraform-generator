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
        name: 'moduleName',
        message: 'Enter the module name : ',
        default: 'terraform-aws-',
        validate: input => input.length > 0
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
      }    
    ]);
  }

  writing() {
    this.destinationRoot(this.answers.moduleName);

    var gitCloneUrl = `${this.answers.sourceControlPrefix}${this.answers.moduleName}.git`

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
      this.templatePath('.gitignore'),
      this.destinationPath('.gitignore')
    );

    this.fs.copy(
      this.templatePath('.tflint.hcl'),
      this.destinationPath('.tflint.hcl')
    );

    this.fs.copy(
      this.templatePath('docs'),
      this.destinationPath('docs')
    );

    this.fs.copyTpl(
      this.templatePath('Makefile'),
      this.destinationPath('Makefile')
    );

    this.fs.copyTpl(
      this.templatePath('README.yaml'),
      this.destinationPath('README.yaml'), {
        moduleName: this.answers.moduleName.toLowerCase(),
        gitCloneUrl: gitCloneUrl,
        buildImageUrl: buildStatusUrl,
        buildStatusImageUrl: buildStatusImageUrl
      }
    );

    this.fs.copyTpl(
      `${this.templatePath()}/**/*.tf`,
      this.destinationRoot()
    );

  }
};