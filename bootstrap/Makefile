export AWS_PROFILE=administrator
export AWS_REGION=us-east-2

#STATE_S3BUCKET:=playground-tfstate-$(shell uuidgen -t | cut -c1-8)
export STATE_S3BUCKET:=$(shell gh repo view --json owner,name --jq '.owner.login + "-" + .name' )--state
export STATE_LOCK_DYNAMODB=$(STATE_S3BUCKET)-lock
export STATE_KEYALIAS=alias/$(STATE_S3BUCKET)-key
export TF_VAR_profile=$(AWS_PROFILE)
export TF_VAR_region=$(AWS_REGION)

export TERRAFORM=terraform
export PLAN=out.tfplan
export AWS_PAGER=""
export AWS_DEFAULT_OUTPUT=json

all:	init plan ask apply gh_update

install: init plan apply gh_update

init:
	./deploy --bootstrap

plan:
	$(TERRAFORM) fmt
	$(TERRAFORM) validate
	$(TERRAFORM) plan -out=$(PLAN)

ask:
	read -p 'OK? [Y/ctrl-c]' dummy

apply:
	$(TERRAFORM) apply $(PLAN)

destroy:
	./deploy --destroy-really-all

	-gh variable delete AWS_REGION
	-gh variable delete AWS_USER
	-gh variable delete AWS_GITHUB_ROLE
	-gh variable delete STATE_S3BUCKET

clean: destroy

gh_update:
	# gh secret set AWS_ACCESS_KEY_ID --body $(shell $(TERRAFORM) output -raw playground_access_key)
	# gh secret set AWS_SECRET_ACCESS_KEY --body $(shell $(TERRAFORM) output -raw playground_secret_key)
	gh variable set AWS_REGION --body $(shell $(TERRAFORM) output -raw playground_region)
	gh variable set AWS_USER --body $(shell $(TERRAFORM) output -raw playground_user)
	gh variable set AWS_GITHUB_ROLE --body $(shell $(TERRAFORM) output -raw playground_github_role)
	gh variable set STATE_S3BUCKET --body "$(STATE_S3BUCKET)"

sh:
	-@bash


.PHONY: all install init plan ask apply destroy clean gh_update sh
