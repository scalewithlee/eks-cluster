fmt:
	terraform fmt -recursive infrastructure/terraform
	cd applications/hash-service && go fmt
