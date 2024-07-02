############### VPC #################


# VPC for the platform
resource "aws_vpc" "web_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name               = "web-vpc"
  }
}

# Management subnet
resource "aws_subnet" "mgmt" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone    = "${var.region}a"
  tags = {
    Name = "mgmt"
  }
}

# RDS 1a subnet
resource "aws_subnet" "rds_1" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone    = "${var.region}a"
  tags = {
    Name = "rds-1"
  }
}

# RDS 1b subnet
resource "aws_subnet" "rds_2" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone    = "${var.region}b"
  tags = {
    Name = "rds-2"
  }
}

# RDS 1c subnet
resource "aws_subnet" "rds_3" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone    = "${var.region}c"
  tags = {
    Name = "rds-3"
  }
}

# Web subnet
resource "aws_subnet" "web_1" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone    = "${var.region}a"
  tags = {
    Name = "web-1"
  }
}

resource "aws_subnet" "web_2" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 5)
  availability_zone    = "${var.region}b"
  tags = {
    Name = "web-2"
  }
}

resource "aws_subnet" "web_3" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 6)
  availability_zone    = "${var.region}c"
  tags = {
    Name = "web-3"
  }
}

# Hosts subnet
resource "aws_subnet" "hosts_1" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 7)
  availability_zone    = "${var.region}a"
  tags = {
    Name = "hosts-1"
  }
}

resource "aws_subnet" "hosts_2" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 8)
  availability_zone    = "${var.region}b"
  tags = {
    Name = "hosts-2"
  }
}

resource "aws_subnet" "hosts_3" {
  vpc_id               = aws_vpc.web_vpc.id
  cidr_block           = cidrsubnet(var.vpc_cidr, 8, 9)
  availability_zone    = "${var.region}c"
  tags = {
    Name = "hosts-3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    Name = "edge-igw"
  }
}

# DHCP Options set
resource "aws_vpc_dhcp_options" "dhcpopts" {
  domain_name          = "${var.region}.compute.internal"
  domain_name_servers  = [ "AmazonProvidedDNS" ]
  tags = {
    Name = "dhcp"
  }
}
resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {
  vpc_id          = aws_vpc.web_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcpopts.id
}

# Routes
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.web_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
