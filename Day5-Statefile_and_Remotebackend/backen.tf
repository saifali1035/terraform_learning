terraform {
  backend "s3" {
    bucket = "saif-state-file-bucket"
    key    = "mumbai-state-file/terraform.tfstate"
    region = "ap-south-1"
  }
}
