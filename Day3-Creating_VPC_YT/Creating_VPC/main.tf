provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "Day3_VPC" {
  cidr_block = "10.0.0.0/24"
   tags = {
     Name = "Day3_VPC" 
   }
}

resource "aws_subnet" "Day3_Private_Subnet" {
  vpc_id = aws_vpc.Day3_VPC.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Day3_Private_Subnet"
  }
}

resource "aws_subnet" "Day3_Public_Subnet" {
  vpc_id = aws_vpc.Day3_VPC.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Day3_Public_Subnet"
  }
}

resource "aws_internet_gateway" "Day3_Internet_Gateway" {
  vpc_id = aws_vpc.Day3_VPC.id
  tags = {
    Name = "Day3_Internet_Gateway"
  }
}

resource "aws_route_table" "Day3_Public_Route_Table" {
  vpc_id = aws_vpc.Day3_VPC.id
  tags = {
    Name = "Day3_Public_Route_Table"
  }
  
}

resource "aws_route" "Day3_Public_Route" {
  route_table_id = aws_route_table.Day3_Public_Route_Table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.Day3_Internet_Gateway.id
}

resource "aws_route_table_association" "Day3_Public_Route_Table_Association" {
  subnet_id = aws_subnet.Day3_Public_Subnet.id
  route_table_id = aws_route_table.Day3_Public_Route_Table.id
}


/*resource "aws_security_group" "Day3_Security_Group_ssh" {
  vpc_id = aws_vpc.Day3_VPC.id
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/25"]
  }
tags = {
  Name = "Day3_Security_Group_ssh"
}

}*/

/*resource "aws_instance" "Day3_Public_Instance" {
  subnet_id = aws_subnet.Day3_Public_Subnet.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  vpc_security_group_ids = [ aws_security_group.Day3_Security_Group_ssh.id ]
tags = {
  Name = "Day3_Public_Instance"
}
}*/

resource "aws_security_group" "Day3_Security_Group_ssh_Private" {
  vpc_id = aws_vpc.Day3_VPC.id
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
  Name = "Day3_Security_Group_ssh_Private"
}

}


resource "aws_instance" "Day3_Private_Instance" {
  subnet_id = aws_subnet.Day3_Private_Subnet.id
  ami = "ami-0e670eb768a5fc3d4" #Amazon Linux 2023 AMI 2023.3.20240219.0 x86_64 HVM kernel-6.1
  instance_type = "t2.micro" 
  key_name = "Project1"
  vpc_security_group_ids = [ aws_security_group.Day3_Security_Group_ssh_Private.id ]
tags = {
  Name = "Day3_Private_Instance"
}
}

resource "aws_eip" "Day3_EIP_For_NAT" {
  domain = "vpc"
  tags = {
    Name = "Day3_EIP_For_NAT"
  }
}

resource "aws_nat_gateway" "Day3_NAT_Gateway" {
  subnet_id = aws_subnet.Day3_Public_Subnet.id
  allocation_id = aws_eip.Day3_EIP_For_NAT.id
  tags = {
    Name = "Day3_NAT_Gateway"
  }
}

resource "aws_route_table" "Day3_Private_Route_Table" {
  vpc_id = aws_vpc.Day3_VPC.id
   tags = {
     Name = "Day3_Private_Route_Table"
   }
}

resource "aws_route" "Day3_Private_Route" {
  route_table_id = aws_route_table.Day3_Private_Route_Table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.Day3_NAT_Gateway.id

}

resource "aws_route_table_association" "Day3_Private_Route_Table_Association" {
  route_table_id = aws_route_table.Day3_Private_Route_Table.id
  subnet_id = aws_subnet.Day3_Private_Subnet.id
}

resource "aws_ec2_instance_connect_endpoint" "example" {
  subnet_id = aws_subnet.Day3_Private_Subnet.id
  preserve_client_ip = true

}