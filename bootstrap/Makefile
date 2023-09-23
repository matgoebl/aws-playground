export AWS_PROFILE=administrator
export AWS_REGION=us-east-2

#STATE_S3BUCKET:=playground-tfstate-$(shell uuidgen -t | cut -c1-8)
export STATE_S3BUCKET:=$(shell gh repo view --json owner,name --jq '.owner.login + "-" + .name' )--state
export STATE_LOCK_DYNAMODB=$(STATE_S3BUCKET)-lock
export TF_VAR_profile=$(AWS_PROFILE)
export TF_VAR_region=$(AWS_REGION)
export TF_VAR_state_s3bucket=$(STATE_S3BUCKET)
export TF_VAR_state_dynamodb=$(STATE_LOCK_DYNAMODB)

export TERRAFORM=terraform
export PLAN=out.tfplan
export AWS_PAGER=""
export AWS_DEFAULT_OUTPUT=json

all:	init plan ask apply gh_update

install: init plan apply gh_update

init:
	@echo '*** Create AWS S3 Bucket and DynamoDB for holding the terraform remote state, if not already done...'
	aws s3api list-objects --bucket $(STATE_S3BUCKET) >/dev/null 2>&1 || \
	 aws s3api create-bucket --bucket $(STATE_S3BUCKET) --acl private --create-bucket-configuration LocationConstraint=$(AWS_REGION)
	aws s3api put-bucket-encryption --bucket $(STATE_S3BUCKET) --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\": \"AES256\"}}]}"
	aws dynamodb describe-table --table-name $(STATE_LOCK_DYNAMODB) >/dev/null 2>&1 || \
	 aws dynamodb create-table --table-name $(STATE_LOCK_DYNAMODB) --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST

	$(TERRAFORM) init \
	 -backend-config="bucket=$(STATE_S3BUCKET)" \
	 -backend-config="key=$(STATE_S3BUCKET)-bootstrap" \
	 -backend-config="dynamodb_table=$(STATE_LOCK_DYNAMODB)" \
	 -backend-config="region=$(AWS_REGION)" \
	 -backend-config="profile=$(AWS_PROFILE)"

	@echo '*** Import AWS S3 Bucket and DynamoDB ressources for holding the terraform remote state, if not already done...'
	$(TERRAFORM) state show aws_s3_bucket.state_s3bucket >/dev/null 2>&1 || \
	 $(TERRAFORM) import aws_s3_bucket.state_s3bucket $(STATE_S3BUCKET)
	$(TERRAFORM) state show aws_dynamodb_table.state_dynamodb >/dev/null 2>&1 || \
	 $(TERRAFORM) import aws_dynamodb_table.state_dynamodb $(STATE_LOCK_DYNAMODB)

plan:
	$(TERRAFORM) fmt
	$(TERRAFORM) validate
	$(TERRAFORM) plan -out=$(PLAN)

ask:
	read -p 'OK? [Y/ctrl-c]' dummy

apply:
	$(TERRAFORM) apply $(PLAN)

destroy:
	$(TERRAFORM) destroy -auto-approve
	rm -rf $(PLAN)
	-aws s3 rb s3://$(STATE_S3BUCKET) --force 
	-aws dynamodb delete-table --table-name $(STATE_LOCK_DYNAMODB)
	# -gh secret delete AWS_ACCESS_KEY_ID
	# -gh secret delete AWS_SECRET_ACCESS_KEY
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
