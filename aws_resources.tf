
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "allow_http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
 

  tags = {
    Name = "lab1"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "lab1-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "lab1-igw"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_instance" "apache" {
  ami           = "ami-053b0d53c279acc90"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"                                

  security_groups = [aws_security_group.allow_http.id]
  subnet_id     = aws_subnet.mysubnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "apache-instance"
  }
}