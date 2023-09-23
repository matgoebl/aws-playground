export AWS_ACCESS_KEY_ID?=$(shell cat ./.playground.key)
export AWS_SECRET_ACCESS_KEY?=$(shell cat ./.playground.secret)
export AWS_REGION?=$(shell cat ./.playground.region)
export STATE_S3BUCKET?=$(shell cat ./.playground.state_s3bucket)
export STATE_LOCK_DYNAMODB=$(STATE_S3BUCKET)-lock

TERRAFORM=terraform
PLAN=out.tfplan

all:	init plan ask apply curl

install: init plan apply

init:
	$(TERRAFORM) init -reconfigure \
	 -backend-config="bucket=$(STATE_S3BUCKET)" \
	 -backend-config="key=$(STATE_S3BUCKET)-main" \
	 -backend-config="dynamodb_table=$(STATE_LOCK_DYNAMODB)" \
	 -backend-config="region=$(AWS_REGION)" \
	 -backend-config="profile=$(AWS_PROFILE)"

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

clean: destroy


curl:
	curl -i "$(shell $(TERRAFORM) output -raw website_url)"

summary:
	@echo "### Deployment Result"
	@echo "- $(shell $(TERRAFORM) output -raw website_url)"


export LAMBDA_NAME=page_updater
export TF_VAR_lambda_name=$(LAMBDA_NAME)


call:
	aws lambda invoke --function-name $(LAMBDA_NAME) --cli-binary-format raw-in-base64-out --payload '{"action": "do_something","arguments": [1,2,3]}' --no-cli-pager tmp.txt
	@echo ---; cat tmp.txt; echo

logs:
	aws logs filter-log-events --log-group-name /aws/lambda/$(LAMBDA_NAME) --filter-pattern 'INFO' | jq -j '.events[].message'

tail:
	aws logs tail /aws/lambda/$(LAMBDA_NAME) --follow

get:
	aws s3 ls s3://"$(shell $(TERRAFORM) output -raw bucket_name)"
	aws s3 cp s3://"$(shell $(TERRAFORM) output -raw bucket_name)"/index.html -

sh:
	-@bash


.PHONY: all install init plan ask apply destroy clean curl call logs tail get sh
