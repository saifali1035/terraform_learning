provider "aws" {
    region = "ap-south-1" #Mumbai 
}

resource "aws_instance" "Example" {
    ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
    instance_type = "t2.micro"  
    subnet_id = "subnet-008698a4ad5513812" #Deafult Subnet for Mumbai -1b
    key_name = "Project1"
    tags = {
      Name = "Example Server"
    }
}