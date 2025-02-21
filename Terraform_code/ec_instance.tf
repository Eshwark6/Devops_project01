provider "aws" {
  region = "us-east-1"
  
}

resource "aws_instance" "Server-1" {
    ami = "ami-053a45fff0a704a47"
    instance_type = "t2.micro"
    key_name = "ec2"
    vpc_security_group_ids = [ aws_security_group.Devops-SG.id ]
    tags = {
        Name = "Server-1"
    }
}

resource "aws_security_group" "Devops-SG" {
  name        = "Dev-SG"
  description = "This group will provide access to EC2"

  tags = {
    Name = "Devops-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_Ingress" {
  security_group_id = aws_security_group.Devops-SG.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4      = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.Devops-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
