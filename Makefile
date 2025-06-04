bin/fatline: .terraform *.sh *.sh.tftpl *.tf modules/include/*.tf
	terraform apply -auto-approve

.terraform:
	terraform init
