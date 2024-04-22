# Terraform Learning Starts at 21st of Feb '24


# Day-5
Terraform State file and remote backend.

named as - terraform.tfstate
Terraform state file act as heart of terraform, it uses the state file to determine what changes need to be applied during the subsequent runs

Terraform state file is created (if not already present), when we we run below command.
```terraform
terraform init
```
when we create changes in our terraform configuration (terraform main.tf file), and run below
```terraform
terraform apply
```
terraform reads the configuration file and **compares the desired state with current state** (It is recorded in the state file).

Drawbacks that comes with state file
