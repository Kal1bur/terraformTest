terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
  backend "s3" {
    bucket = "robt-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

#Create VPC; CIDR 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "${var.default_tags.env}-VPC"
  }
}

#Public Subnets 10.0.0.0/24
resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Public-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

#Private Subnets 10.0.0.0/24
resource "aws_subnet" "private" {
  count      = var.private_subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count)
  tags = {
    "Name" = "${var.default_tags.env}-Private-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

#IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.default_tags.env}-Internet-Gateway"
  }
}

#Public Route Table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_route" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

#Private Route Table
resource "aws_route_table" "route_table_local" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-Private-Route-Table"
  }
}

resource "aws_route_table_association" "local_private_route" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.route_table_local.id
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.route_table_local.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main_nat.id
}

#EIP
resource "aws_eip" "nat-eip" {
  vpc = true
}

#NGW
resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.default_tags.env}-NGW"
  }
}
