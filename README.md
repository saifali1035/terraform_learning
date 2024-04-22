# Terraform Learning Starts at 21st of Feb '24

# Prerequisite
1. Install aws cli and terraform
2. AWS Account and user created
3. AWS user account credentails
4. Configure aws cli

# Day-1
Basics of terraform.
Knowledge about provider,resources,data and output
We created a Ec2 instance in AWS using the configuration file.
```HCL
provider "aws" {
    region = "ap-south-1" #Mumbai 
}

resource "aws_instance" "Example" {
    ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
    instance_type = "t2.micro"  
    //subnet_id = "subnet-008698a4ad5513812" #Deafult Subnet for Mumbai -1b
    key_name = "Project1"
    tags = {
      Name = "Example Server"
    }
}
```
*Points to remember*
1. key_name = "Project1" can only be defined and will not be created by terraform if not present.


# Day-2 and Day-3
We are trying to create VPC using ChatGPT on Day2 while using YT as refrence on Day3

# Day-4
Learning and using modules, using modules we can eleminate the need of rewriting code for similiar infrastructures.

# Day-5
Terraform State file and remote backend.

named as - terraform.tfstate
Terraform state file act as heart of terraform, it uses the state file to determine what changes need to be applied during the subsequent runs

Terraform state file is created *(if not already present)*, when we we run below command.
```terraform
terraform init
```
when we create changes in our terraform configuration *(terraform main.tf file)*, and run below
```terraform
terraform apply
```
terraform reads the configuration file and **compares the desired state with current state** *(It is recorded in the state file)*.

Drawbacks that comes with state file -
1. Accidental deletion of the state file can cause issues as terraform will loose track of the current state of the infrastructure.
2. Any sensetive info written in state file will be exposed if a vcs like github is being used to store state file.
3. It is hard to keep track of state file if github is being used to keep it available between all the users in team. *(As terraform state file is updated only post changes are made in the infra and any miss in pushing the updated state file to github can cause state file to loose track of changes made)*.

Overcoming these using **Remote Backend Configuration**, we can use cloud, local fs or terraform cloud for this.
When an update in state file will happen, the updated file will get stored in the defined backend.
```HCL
terraform {
  backend "s3" {
    bucket = "saif-state-file-bucket"
    key    = "mumbai-state-file/terraform.tfstate" #we can customize the path where we can our state file
    region = "ap-south-1"
  }
}
```
<img width="1500" alt="image" src="https://github.com/saifali1035/terraform_learning/assets/37189361/09c772f4-97ac-4ce1-a73b-f3e9a79d86e2">
<img width="1500" alt="image" src="https://github.com/saifali1035/terraform_learning/assets/37189361/af443af5-2124-48d4-a7ec-3866a23459ca">
<img width="1500" alt="image" src="https://github.com/saifali1035/terraform_learning/assets/37189361/6c9fa219-6787-4e86-9270-207cf1df9dcb">

*Points to remember*
1. Bucket should be present before using this.
2. Creation of bucket manually is recommended while terraform can be used.
3. Run terraform init after declaring this.

