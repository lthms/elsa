.PHONY: deploy
deploy: main.ign
	terraform apply -var-file=main.tfvars

destroy: main.ign
	terraform destroy -var-file=main.tfvars

main.ign: main.bu
	butane -d . $< > $@
