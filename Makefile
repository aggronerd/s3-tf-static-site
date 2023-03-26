clean:
	rm -Rf .terraform/ && \
		mkdir -p output/

prerequisites:
	ifndef ENV
		$(error ENV variable is not set. Please set and try again.)
	endif

tfinit: clean
	terraform init -backend-config="environments/$(ENV)/state.tfvars"

plan:
	terraform plan -var-file="environments/$(ENV)/variables.tfvars" -out="output/$(ENV).plan"

apply:
	terraform apply "output/$(ENV).plan"

destroy: tfinit
	terraform destroy -var-file="environments/$(ENV)/variables.tfvars"