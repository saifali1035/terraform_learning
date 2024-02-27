provider "aws" {
    region = "ap-south-1"
}

#creating VPC with 256 IPs
resource "aws_vpc" "Day2_VPC" {
    cidr_block = "10.0.0.0/24"

    tags = {
      Name = "Day2_VPC"
    }
}

#use all available AZs in the Region
data "aws_availability_zones" "available" {
  state = "available"
}

#route table to allow connections from IG to Bastion and allows traffic#
#from private subnet to internet# 
resource "aws_route_table" "Day2_RT_IG" {
  vpc_id = aws_vpc.Day2_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Day2_IG.id
  }

  tags = {
    Name = "Day2_RT_IG"
  }
}

resource "aws_route_table" "Day2_RT_NAT" {
  vpc_id = aws_vpc.Day2_VPC.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Day2_PRIS_NATGW.id
  }

  tags = {
    Name = "Day2_RT_NAT"
  }
}


resource "aws_route_table_association" "Adding_to_Day2_PUBS" {
  subnet_id = aws_subnet.Day2_PUBS.id
  route_table_id = aws_route_table.Day2_RT_IG.id
}
resource "aws_route_table_association" "Adding_to_Day2_PRIS" {
  subnet_id = aws_subnet.Day2_PRIS.id
  route_table_id = aws_route_table.Day2_RT_NAT.id
}






























##############PUBLIC SUBNET#######################



#creating public subnet in the first AZs with 16 IPs
resource "aws_subnet" "Day2_PUBS" {
  vpc_id = aws_vpc.Day2_VPC.id
  cidr_block = "10.0.0.0/28"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Day2_PUBS"
  }
}

#Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "Day2_IG" {
  vpc_id = aws_vpc.Day2_VPC.id

  tags = {
    Name = "Day2_IG"
  }
}

#Bastion Host to connect to Private Instances
resource "aws_instance" "Day2_PUBS_Bastion_host" {
  subnet_id = aws_subnet.Day2_PUBS.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  security_groups = [ aws_security_group.Day2_SG_SSH_BH.id ]


  tags = {
    Name = "Day2_PUBS_Bastion_host"
  }

   # Associate Elastic IP directly in the instance definition
  associate_public_ip_address = true
  
}

#Security Group that allows ssh in Bastion host
resource "aws_security_group" "Day2_SG_SSH_BH" {
  name = "Allow ssh"
  description = "Allow ssh to bastion host as it is in Public subnet"
  vpc_id = aws_vpc.Day2_VPC.id
  
  ingress {

    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Elastic IP
resource "aws_eip" "public_instance_eip" {
  instance = aws_instance.Day2_PUBS_Bastion_host.id  # Replace with the ID of your public EC2 instance
}


###############################################################













##############PRIVATE SUBNET#######################

#creating private subnet in the first AZs with 16 IPs
resource "aws_subnet" "Day2_PRIS" {
  vpc_id = aws_vpc.Day2_VPC.id
  cidr_block = "10.0.0.128/28"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  

  tags = {
    Name = "Day2_PRIS"
  }
}

#Create an EIP for NAT Gateway
resource "aws_eip" "Day2_EIP" {
  domain = "vpc"

  tags = {
    Name = "Day2_NAT_EIP"
  }
}

#NAT Gateway to allow inbount connections in Private Subnet
resource "aws_nat_gateway" "Day2_PRIS_NATGW" {
  subnet_id = aws_subnet.Day2_PUBS.id
  allocation_id = aws_eip.Day2_EIP.id

  tags = {
    Name = "Day2_PRIS_NATGW"
  }
}

#EC2 Instance in Private Subnet
resource "aws_instance" "Day2_PRIS_EC2" {
  subnet_id = aws_subnet.Day2_PRIS.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  security_groups = [ aws_security_group.Day2_SG_SSH__FROM_BH.id ]

  tags = {
    Name = "Day2_PRIS_EC2"
  }
}

#Security Group that  ssh from Bastion host to private instances
resource "aws_security_group" "Day2_SG_SSH__FROM_BH" {
  name        = "Allow SSH to private EC2"
  description = "Allow SSH from Bastion host to private EC2 instances"
  vpc_id      = aws_vpc.Day2_VPC.id
  
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.Day2_SG_SSH_BH.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with specific CIDR blocks if possible
  }
}

########################################################
















