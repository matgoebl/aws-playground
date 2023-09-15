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
