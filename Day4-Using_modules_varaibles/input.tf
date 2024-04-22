variable "ami_value" {
  description = "AMI Value for instance"
  type = string
  default = "ami-0e670eb768a5fc3d4"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  
}