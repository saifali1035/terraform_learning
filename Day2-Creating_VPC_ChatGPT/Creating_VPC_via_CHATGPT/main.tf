provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "ChatGpt-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                 = aws_vpc.my_vpc.id
  cidr_block             = "10.0.0.0/25"
  availability_zone      = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ChatGpt-Public-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id             = aws_vpc.my_vpc.id
  cidr_block         = "10.0.0.128/26"
  availability_zone  = "ap-south-1b"
  tags = {
    Name = "ChatGpt-Private-Subnet"
  }
}

resource "aws_instance" "bastion_host" {
  ami           = "ami-0e670eb768a5fc3d4"  # specified AMI for the bastion host
  instance_type = "t2.micro"  # adjust the instance type as needed
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "Project1"  # use "Project1" key pair
  security_groups = [ aws_security_group.bastion_sg.id ]
  tags = {
    Name = "ChatGpt-Bastion-Host"
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-0e670eb768a5fc3d4"  # specified AMI for the private instance
  instance_type = "t2.micro"  # adjust the instance type as needed
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "Project1"  # use "Project1" key pair
  security_groups = [ aws_security_group.private_instance_sg.id ]
  tags = {
    Name = "ChatGpt-Private-Instance"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "Security group for private instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "ChatGpt-Internet-Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion_host.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}



resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "private_route" {
  route_table_id          = aws_route_table.private_route_table.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id           = aws_nat_gateway.my_nat_gateway.id
}
