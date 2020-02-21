APPLICATION_STACK_NAME?=AccountFactory
GITHUB_OAUTH_TOKEN?=$(shell bash -c 'read -p "GITHUB_OAUTH_TOKEN: " var; echo $$var')
GITHUB_REPO?=aws-account-factory
GITHUB_OWNER?=LandoopRnD
GITHUB_BRANCH?=feat/cloud-210
AWS_DEFAULT_REGION?=us-east-1
# Do this first to configure the awscli
setup:
	cat ~/.aws/credentials
	aws configure --profile $(APPLICATION_STACK_NAME)
# Function to create a pipeline - can't be automated
pipeline:
	-@unset AWS_DEFAULT_REGION; \
	aws cloudformation create-stack \
		--profile $(APPLICATION_STACK_NAME) \
		--stack-name Pipeline$(APPLICATION_STACK_NAME) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--template-body file://pipeline.yml \
		--output text \
		--parameters \
		  ParameterKey=ApplicationStackName,ParameterValue=$(APPLICATION_STACK_NAME) \
		  ParameterKey=GitHubOAuthToken,ParameterValue=$(GITHUB_OAUTH_TOKEN) \
		  ParameterKey=GitHubOwner,ParameterValue=$(GITHUB_OWNER) \
		  ParameterKey=GitHubRepo,ParameterValue=$(GITHUB_REPO) \
		  ParameterKey=GitHubBranch,ParameterValue=$(GITHUB_BRANCH)
# Function to update a pipeline after its been created - can't be automated
update_pipeline:
	-@unset AWS_DEFAULT_REGION; \
	aws cloudformation update-stack \
		--profile $(APPLICATION_STACK_NAME) \
		--stack-name Pipeline$(APPLICATION_STACK_NAME) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--template-body file://pipeline.yml \
		--output text \
		--parameters \
		  ParameterKey=ApplicationStackName,ParameterValue=$(APPLICATION_STACK_NAME) \
		  ParameterKey=GitHubOAuthToken,ParameterValue=$(GITHUB_OAUTH_TOKEN) \
		  ParameterKey=GitHubOwner,ParameterValue=$(GITHUB_OWNER) \
		  ParameterKey=GitHubRepo,ParameterValue=$(GITHUB_REPO) \
		  ParameterKey=GitHubBranch,ParameterValue=$(GITHUB_BRANCH)
# Send code to github to trigger a release
release:
	@git status
	$(eval COMMENT := $(shell bash -c 'read -e -p "Comment: " var; echo $$var'))
	@git add --all; \
	 git commit -m "$(COMMENT)"; \
	 git push
# buildspec.yml phase
install:
	@echo install started $(shell date)
	@aws s3 cp AccountCreationLambda.zip s3://
# buildspec.yml phase
pre_build:
	@echo pre_build started $(shell date)
# buildspec.yml phase
build:
	@echo build started $(shell date)
# buildspec.yml phase
post_build:
	@echo post_build started $(shell date)