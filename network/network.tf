resource "aws_vpc" "webappvpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "webappigw" {
  vpc_id = aws_vpc.webappvpc.id
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.webappvpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private-subnet-Az1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.webappvpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-subnet-Az2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.webappvpc.id
  cidr_block = var.subnet3_cidr
  availability_zone = "eu-west-2c"

  tags = {
    Name = "public-subnet-Az3"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.webappvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw-ec2.id
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.webappvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webappigw.id
  }
}

resource "aws_route_table_association" "private-associate1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-associate2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "public-associate" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_security_group" "dbtier-sg" {
  name = "allow_postgres_ingress"
  description = "SG to allow database access from app"
  vpc_id = aws_vpc.webappvpc.id

  ingress {
    description = "database access from app"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "allow_postgres_access"
  }
  
}


resource "aws_security_group" "web-tier-sg" {
  name = "web-tier-sg"
  description = "allow user access coming through NLB"
  vpc_id = aws_vpc.webappvpc.id

  ingress {
    description = "https access from nlb"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "allow yum repo access"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-tier-sg"
  }
  
}

resource "aws_eip" "nlb-ip" {
  vpc      = true
}

resource "aws_eip" "natgw-ip" {
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw-ec2" {
  allocation_id = aws_eip.natgw-ip.id
  subnet_id     = aws_subnet.subnet3.id

  tags = {
    Name = "nat-gw-ec2"
  }
  depends_on = [aws_internet_gateway.webappigw]
}
