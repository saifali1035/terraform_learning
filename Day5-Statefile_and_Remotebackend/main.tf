provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "instance_Day5" {
    ami = "ami-001843b876406202a"
    instance_type = "t2.micro"
    
}

resource "aws_s3_bucket" "saif-state-file-bucket" {
  bucket = "saif-state-file-bucket"
}
