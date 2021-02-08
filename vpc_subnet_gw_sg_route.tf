resource "aws_vpc" "docdb-vpc" {
  cidr_block       = "172.32.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "docdb"
  }
}

resource "aws_subnet" "subnet_docdb_1" {
  vpc_id     = aws_vpc.docdb-vpc.id
  cidr_block = "172.32.1.0/24"
  tags = {
    Name = "docdb"
  }
}

resource "aws_subnet" "subnet_docdb_2" {
  vpc_id     = aws_vpc.docdb-vpc.id
  cidr_block = "172.32.2.0/24"
  tags = {
    Name = "docdb"
  }
}

resource "aws_security_group" "sg_docdb" {
  name        = "sg_docdb"
  vpc_id      = aws_vpc.docdb-vpc.id
  description = "Security Group for DocumentDB"

  ingress {
    cidr_blocks = [
    "172.32.0.0/16"]
    protocol  = "icmp"
    from_port = 8
    to_port   = 0
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.32.0.0/16"]
    #      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = {
    Name = "docdb"
  }
}

resource "aws_internet_gateway" "gw_docdb" {
  vpc_id = aws_vpc.docdb-vpc.id
  tags = {
    Name = "docdb"
  }
}

resource "aws_route" "route" {
  gateway_id             = aws_internet_gateway.gw_docdb.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_vpc.docdb-vpc.default_route_table_id
}