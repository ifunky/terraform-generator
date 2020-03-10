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
      },
    ]);
  }

  writing() {
    this.destinationRoot(this.answers.moduleName);

    this.fs.copy(
      this.templatePath('.gitlab-ci.yml'),
      this.destinationPath('.gitlab-ci.yml')
    );

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
      }
    );

    this.fs.copyTpl(
      `${this.templatePath()}/**/*.tf`,
      this.destinationRoot()
    );

  }
};