provider "aws" {
    region = "ap-south-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Day2_YT_VPC" {
    cidr_block = "10.0.0.0/24"

    tags = {
      Name = "Day2_VPC"
    }
}

resource "aws_subnet" "Day2_YT_PUBS" {
  vpc_id = aws_vpc.Day2_YT_VPC.id
  cidr_block = "10.0.0.0/25"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Day2_PUBS"
  }
}

resource "aws_subnet" "Day2_YT_PRIS" {
  vpc_id = aws_vpc.Day2_YT_VPC.id
  cidr_block = "10.0.0.128/25"
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name = "Day2_PRIS"
  }
}

resource "aws_route_table" "Day2_YT_RT_IG" {
  vpc_id = aws_vpc.Day2_YT_VPC.id
  /*route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Day2_YT_IG.id
  }*/

  tags = {
    Name = "Day2_RT_IG"
  }
}


resource "aws_route_table" "Day2_YT_RT_NAT" {
  vpc_id = aws_vpc.Day2_YT_VPC.id
   /* route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Day2_YT_PRIS_NATGW.id
  }*/

  tags = {
    Name = "Day2_RT_NAT"
  }
}

resource "aws_route_table_association" "Adding_to_YT_Day2_PUBS" {
  subnet_id = aws_subnet.Day2_YT_PUBS.id
  route_table_id = aws_route_table.Day2_YT_RT_IG.id
}

resource "aws_route_table_association" "Adding_to_YT_Day2_PRIS" {
  subnet_id = aws_subnet.Day2_YT_PRIS.id
  route_table_id = aws_route_table.Day2_YT_RT_NAT.id
}

resource "aws_internet_gateway" "Day2_YT_IG" {
  vpc_id = aws_vpc.Day2_YT_VPC.id

  tags = {
    Name = "Day2_IG"
  }
}

resource "aws_route" "DAY2_YT_PUBRT" {
  route_table_id = aws_route_table.Day2_YT_RT_IG.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.Day2_YT_IG.id
}

resource "aws_eip" "DAY2_YT_EIP_NAT" {

  domain   = "vpc"
}

resource "aws_nat_gateway" "DAY2_YT_NAT" {
  allocation_id = aws_eip.DAY2_YT_EIP_NAT.id
  subnet_id = aws_subnet.Day2_YT_PUBS.id
}


resource "aws_route" "DAY2_YT_PISRT" {
  route_table_id = aws_route_table.Day2_YT_RT_NAT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.Day2_YT_IG.id
  
}

resource "aws_security_group" "Day2_YT_SG_SSH_BH" {
  name = "Allow ssh"
  description = "Allow ssh to bastion host as it is in Public subnet"
  vpc_id = aws_vpc.Day2_YT_VPC.id
  
  ingress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "Day2_YT_PUBS_Bastion_host" {
  subnet_id = aws_subnet.Day2_YT_PUBS.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  vpc_security_group_ids = [ aws_security_group.Day2_YT_SG_SSH_BH.id ]


  tags = {
    Name = "Day2_PUBS_Bastion_host"
  }

   # Associate Elastic IP directly in the instance definition
  associate_public_ip_address = true
  
}


resource "aws_instance" "Day2_YT_PRIS_EC2" {
  subnet_id = aws_subnet.Day2_YT_PRIS.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  vpc_security_group_ids = [ aws_security_group.Day2_YT_SG_SSH_BH.id ]

  tags = {
    Name = "Day2_PRIS_EC2"
  }
}

