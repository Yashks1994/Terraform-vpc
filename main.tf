provider "aws" {
    access_key = ""
    secret_key = ""
    region = "us-west-2"
}

resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = "true"
    tags = {
      Name = "myvpc"
  }
}

resource "aws_subnet" "myvpc-public-1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-west-2a"

    tags = {
      Name = "myvpc-public-1"
    }
}

resource "aws_subnet" "myvpc-private-1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-west-2a"

    tags = {
      Name = "myvpc-private-1"
    }
}

resource "aws_internet_gateway" "myvpc-gw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
      Name = "myvpc"
  }
}

resource "aws_route_table" "myvpc-public" {
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myvpc-gw.id
    }

    tags = {
      Name = "myvpc-public-1"
    }
}

resource "aws_route_table_association" "myvpc-public-1-a" {
  subnet_id      = aws_subnet.myvpc-public-1.id
  route_table_id = aws_route_table.myvpc-public.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.myvpc-public-1.id
    depends_on    = [aws_internet_gateway.myvpc-gw]
}

resource "aws_route_table" "myvpc-private" {
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat-gw.id
    }
    tags = {
      Name = "myvpc-private-1"
    }
}

resource "aws_route_table_association" "myvpc-private-1-a" {
    subnet_id      = aws_subnet.myvpc-private-1.id
    route_table_id = aws_route_table.myvpc-private.id
}

resource "aws_instance" "webserver" {
    ami = "ami-0d1cd67c26f5fca19"
    instance_type = "t2.micro"
    
    subnet_id = aws_subnet.myvpc-public-1.id
}

resource "aws_instance" "db" {
    ami = "ami-0d1cd67c26f5fca19"
    instance_type = "t2.micro"
    
    subnet_id = aws_subnet.myvpc-private-1.id
}