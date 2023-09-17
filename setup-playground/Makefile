TERRAFORM=terraform
PLAN=out.tfplan

all:	init plan apply

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

gh_update:
	gh secret set AWS_ACCESS_KEY_ID --body $(shell $(TERRAFORM) output -raw playground_access_key)
	gh secret set AWS_SECRET_ACCESS_KEY --body $(shell $(TERRAFORM) output -raw playground_secret_key)
	gh variable set AWS_REGION --body $(shell $(TERRAFORM) output -raw playground_region)
	gh variable set AWS_USER --body $(shell $(TERRAFORM) output -raw playground_user)

.PHONY: all install init plan apply destroy clean
