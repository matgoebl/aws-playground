export AWS_ACCESS_KEY_ID=$(shell cat ../.playground.key)
export AWS_SECRET_ACCESS_KEY=$(shell cat ../.playground.secret)
export AWS_REGION=$(shell cat ../.playground.region)
export TF_VAR_region=$(AWS_REGION)

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

.PHONY: all install init plan apply destroy clean curl
