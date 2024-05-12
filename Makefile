export AWS_ACCESS_KEY_ID?=$(shell cat ./.playground.key)
export AWS_SECRET_ACCESS_KEY?=$(shell cat ./.playground.secret)
export AWS_REGION?=$(shell cat ./.playground.region)
export STATE_S3BUCKET?=$(shell cat ./.playground.state_s3bucket)
export STATE_LOCK_DYNAMODB=$(STATE_S3BUCKET)-lock

TERRAFORM=terraform
PLAN=out.tfplan
VENV=./.venv

all:	init plan ask apply curl

install: init plan apply

setup-devbox:
	curl -sfSL https://direnv.net/install.sh | bash
	curl -sfSL https://get.jetpack.io/devbox | bash
	grep -q 'direnv hook bash' $(HOME)/.bashrc || echo 'eval "$$(direnv hook bash)"' >> $(HOME)/.bashrc
	devbox install
	direnv allow .

setup-playground:
	mkdir -p $(AWS_PLAYGROUND_HOME)/.private/
	if [ -z "$(VIRTUAL_ENV)" ]; then \
	 python3 -m pip install --upgrade pip setuptools wheel virtualenv; \
	 python3 -m virtualenv $(VENV); \
	 . $(VENV)/bin/activate && python3 -m pip install boto3; \
	fi
	python3 -m pip install --upgrade brawser

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

distclean:
	rm -rf $(VENV) .devbox
	find -iname "*.pyc" -delete 2>/dev/null || true
	find -name __pycache__ -type d -exec rm -rf '{}' ';' 2>/dev/null || true
	rm -rf .terraform/providers bootstrap/.terraform/providers
	rm -rf .devbox

curl:
	curl -i "$(shell $(TERRAFORM) output -raw website_url)"

post:
	curl -i -d '' "$(shell $(TERRAFORM) output -raw apigw_url)"/test; echo

summary:
	@echo "### Deployment Result"
	@echo "- $(shell $(TERRAFORM) output -raw website_url)"
	@echo "- $(shell $(TERRAFORM) output -raw apigw_url)"/test


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
