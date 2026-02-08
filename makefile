TEMPLATES = $(wildcard files/*.mustache)
RENDERED = $(TEMPLATES:.mustache=)
FILES = $(wildcard files/*) $(RENDERED)
VARS ?= main.tfvars
TF_VAR_betterstack_source_token ?= unset

%: %.mustache
	@yq -oy -p=hcl $(VARS) | \
		yq ".betterstack_source_token = \"$(TF_VAR_betterstack_source_token)\"" | \
		mustache $< > $@

.PHONY: deploy
deploy: main.ign
	@terraform apply -var-file=$(VARS)

.PHONY: plan
plan: main.ign
	@terraform plan -var-file=$(VARS)

.PHONY: destroy
destroy: main.ign
	@terraform destroy -var-file=$(VARS)

main.ign: main.bu $(FILES)
	@butane -d . $< > $@

.INTERMEDIATE: $(RENDERED) main.ign
