provider "aws" {
  region = "us-east-1"
  
}

#create an EC2 in the defined VPC

resource "aws_instance" "Devops_instance" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    key_name = "ec2"
    vpc_security_group_ids = [aws_security_group.Devops_SG.id]
    subnet_id = aws_subnet.pub_subnet.id
    associate_public_ip_address = true
    for_each = toset(["Jenkins_Master", "Jenkins_Slave", "Ansible"])

    tags = {
        Name = "${each.value}"
    }
  
}

#security group for the EC2 instance

resource "aws_security_group" "Devops_SG" {
  name        = "Devops_SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.DEVOPS_VPC.id

  tags = {
    Name = "allow_tls"
  }
}

#ingress rule for the security group

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.Devops_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#egress rule for the security group

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.Devops_SG.id  
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#VPC

resource "aws_vpc" "DEVOPS_VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Devops_VPC"
  }
}

#Subnet 1 for the VPC

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.DEVOPS_VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}

#Subnet 2 for the VPC

resource "aws_subnet" "pri_subnet" {
  vpc_id     = aws_vpc.DEVOPS_VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}
#Internet Gateway

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.DEVOPS_VPC.id

  tags = {
    Name = "IGW"
  }
}

#Route Table 1 for the public subnet

resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.DEVOPS_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
    }
}

#Route Table 2 for the private subnet

resource "aws_route_table" "pri_route_table" {
  vpc_id = aws_vpc.DEVOPS_VPC.id
}

#Associate the public subnet with the route table

resource "aws_route_table_association" "pub_route_table_association" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_route_table.id
}

#Associate the private subnet with the route table

resource "aws_route_table_association" "pri_route_table_association" {
  subnet_id      = aws_subnet.pri_subnet.id
  route_table_id = aws_route_table.pri_route_table.id
}
