# 1. VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "${var.client_name}-vpc"
    Managed_by ="${var.managed_by}"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.client_name}-igw1"
    Managed_by = "${var.managed_by}"
  }
}
# 3. Public Subnet 1
resource "aws_subnet" "pub_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.client_name}-pub_subnet1"
    Managed_by = "${var.managed_by}"
  }
}
# 4. Private Subnet 1
resource "aws_subnet" "pri_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "${var.client_name}-pri_subnet1"
    Managed_by = "${var.managed_by}"
  }
}
# 5. Public RT 1
resource "aws_route_table" "pub_rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

   tags = {
    Name = "${var.client_name}-pub_rt1"
    Managed_by = "${var.managed_by}"
  }
}

# 6. Private RT 1
resource "aws_route_table" "pri_rt1" {
  vpc_id = aws_vpc.vpc1.id

   tags = {
    Name = "${var.client_name}-pri_rt1"
    Managed_by = "${var.managed_by}"
  }
}
# 7. Public subnet 1 association
resource "aws_route_table_association" "pubsub1_rt1" {
  subnet_id      = aws_subnet.pub_subnet1.id
  route_table_id = aws_route_table.pub_rt1.id
}
# 8. Private Subnet 1 association
resource "aws_route_table_association" "prisub1_rt1" {
  subnet_id      = aws_subnet.pri_subnet1.id
  route_table_id = aws_route_table.pri_rt1.id
}
# 9. Security Group 1
resource "aws_security_group" "sg1" {
  name        = "${var.client_name}-sg1"
 # description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc1.id



  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0",aws_vpc.vpc1.cidr_block]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

    tags = {
    Name = "${var.client_name}-sg1"
    Managed_by = "${var.managed_by}"
  
  }
}

# 10. EC2 - web1
resource "aws_instance" "web1" {
  ami           = "ami-0eb42678783f21d53"
  instance_type = var.my-instance_type
  subnet_id     = aws_subnet.pub_subnet1.id
  key_name      = "demo-keypair"
  associate_public_ip_address  = "true"
  security_groups = [aws_security_group.sg1.id]

 tags = {
    Name = "${var.client_name}-web1"
    Managed_by = "${var.managed_by}"
  
  }
}
# 11. EC2 - DB1
resource "aws_instance" "db1" {
  ami           = "ami-0eb42678783f21d53"
  instance_type = var.my-instance_type
  subnet_id     = aws_subnet.pri_subnet1.id
  key_name      = "demo-keypair"
  security_groups = [aws_security_group.sg1.id]

 tags = {
    Name = "${var.client_name}-db1"
    Managed_by = "${var.managed_by}"
  
  }
}

output "my_web1_public_ip"{
  value = aws_instance.web1.public_ip
  }

   output "my_web1_private_ip"{
  value = aws_instance.web1.private_ip
  }

  output "my_db1_private_ip"{
  value = aws_instance.db1.private_ip
  }

