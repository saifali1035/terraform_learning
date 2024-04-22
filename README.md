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

Drawbacks that comes with state file -
1. Accidental deletion of the state file can cause issues as terraform will loose track of the current state of the infrastructure.
2. Any sensetive info written in state file will be exposed if a vcs like github is being used to store state file.
3. It is hard to keep track of state file if github is being used to keep it available between all the users in team. ( As terraform state file is updated only post changes are made in the infra and any miss in pushing the updated state file to github can cause state file to loose track of changes made).
