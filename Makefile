export AWS_ACCESS_KEY_ID?=$(shell cat ./.playground.key)
export AWS_SECRET_ACCESS_KEY?=$(shell cat ./.playground.secret)
export AWS_REGION?=$(shell cat ./.playground.region)
# export TF_VAR_region=$(AWS_REGION)

TERRAFORM=terraform
PLAN=out.tfplan

all:	init plan apply curl

install: plan
	$(TERRAFORM) apply $(PLAN)

init:
	$(TERRAFORM) init

plan:
	$(TERRAFORM) fmt
	$(TERRAFORM) validate
	$(TERRAFORM) plan -out=$(PLAN)

apply:
	$(TERRAFORM) apply

destroy:
	$(TERRAFORM) destroy -auto-approve
	rm -rf $(PLAN)

clean: destroy


curl:
	curl -i "$(shell $(TERRAFORM) output -raw website_url)"



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


.PHONY: all install init plan apply destroy clean curl call logs tail get sh
