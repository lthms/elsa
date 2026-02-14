TEMPLATES = $(wildcard files/*.mustache)
RENDERED = $(TEMPLATES:.mustache=)
FILES = $(wildcard files/*) $(RENDERED)
CERTS = certs/server-ca.crt certs/server-ca.key certs/client-ca.crt certs/client-ca.key
VARS ?= main.tfvars
TF_VAR_betterstack_source_token ?= unset
TF_VAR_k3s_token ?= unset

.PHONY: deploy
deploy: ## Apply the Terraform configuration
deploy: control_plane.ign agent.ign
	@terraform apply -var-file=$(VARS)

.PHONY: plan
plan: ## Preview infrastructure changes
plan: control_plane.ign agent.ign
	@terraform plan -var-file=$(VARS)

.PHONY: destroy
destroy: ## Tear down all infrastructure
destroy: control_plane.ign agent.ign
	@terraform destroy -var-file=$(VARS)

.PHONY: kubeconfig
kubeconfig: ## Generate a local kubeconfig for the cluster
kubeconfig: certs/client.crt certs/server-ca.crt certs/client.key
	@NODE_IP=$$(terraform output -raw node_ip) && \
	kubectl config set-cluster elsa \
		--server=https://$$NODE_IP:6443 \
		--certificate-authority=certs/server-ca.crt \
		--embed-certs \
		--kubeconfig=elsa.yaml && \
	kubectl config set-credentials elsa-admin \
		--client-certificate=certs/client.crt \
		--client-key=certs/client.key \
		--embed-certs \
		--kubeconfig=elsa.yaml && \
	kubectl config set-context elsa \
		--cluster=elsa \
		--user=elsa-admin \
		--kubeconfig=elsa.yaml && \
	kubectl config use-context elsa --kubeconfig=elsa.yaml

.PHONY: setup
setup: ## Configure local git hooks
setup:
	@git config core.hooksPath .githooks

.PHONY: readme
readme: ## Regenerate README.md from its template
readme: README.md

README.md: README.md.mustache mise.toml variables.tf makefile readme-data.sh
	@./readme-data.sh | mustache README.md.mustache > README.md

control_plane.ign: control_plane.bu $(FILES) $(CERTS)
	@butane -d . $< > $@

agent.ign: agent.bu $(FILES)
	@butane -d . $< > $@

certs/server-ca.key:
	@mkdir -p certs
	@openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $@ 2>/dev/null

certs/server-ca.crt: certs/server-ca.key
	@openssl req -x509 -key $< -out $@ -days 3650 -subj "/CN=k3s-server-ca" 2>/dev/null

certs/client-ca.key:
	@mkdir -p certs
	@openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $@ 2>/dev/null

certs/client-ca.crt: certs/client-ca.key
	@openssl req -x509 -key $< -out $@ -days 3650 -subj "/CN=k3s-client-ca" 2>/dev/null

certs/client.key:
	@mkdir -p certs
	@openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $@ 2>/dev/null

certs/client.crt: certs/client.key certs/client-ca.crt certs/client-ca.key
	@openssl req -new -key certs/client.key -subj "/O=system:masters/CN=admin" 2>/dev/null | \
		openssl x509 -req -CA certs/client-ca.crt -CAkey certs/client-ca.key \
		-CAcreateserial -days 3650 -out $@ 2>/dev/null

FORCE:
.PHONY: FORCE

define mustache_render
@yq -oy -p=hcl $(VARS) | \
	yq ".betterstack_source_token = \"$(TF_VAR_betterstack_source_token)\"" | \
	yq ".k3s_token = \"$(TF_VAR_k3s_token)\"" | \
	mustache $< > $@
endef

# GNU Make's built-in %.sh cancel rule blocks the match-anything rule below
# from applying to .sh targets, so we need a more specific pattern rule.
%.sh: %.sh.mustache FORCE
	$(mustache_render)

%: %.mustache FORCE
	$(mustache_render)

.INTERMEDIATE: $(RENDERED) control_plane.bu agent.bu control_plane.ign agent.ign
