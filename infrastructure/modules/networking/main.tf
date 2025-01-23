data "aws_availability_zones" "available" {}

#create vpc
resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name                = "${var.ecs_cluster_name}-vpc"
  }
}

#create the private subnets
resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "${var.ecs_cluster_name}-private-subnet-${count.index + 1}"
  }
}

#create public subnets
resource "aws_subnet" "public" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.private_subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "${var.ecs_cluster_name}-public-subnet-${count.index + 1}"
  }
}

#create internet gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id                = aws_vpc.main.id

  tags = {
    Name                = "${var.ecs_cluster_name}-igw"
  }
}

#create elatic ip to be attached to nat gateway if private subnets are enabled
resource "aws_eip" "main" {
  count  = var.enable_private_networking ? 1 : 0
  domain = "vpc"
  tags   = { 
    Name = "${var.ecs_cluster_name}-eip" 
  }
  depends_on = [aws_internet_gateway.main]
}

#create nat gatway if private subnets are enabled
resource "aws_nat_gateway" "main" {
  count         = var.enable_private_networking ? 1 : 0
  allocation_id = aws_eip.main[0].id
  subnet_id     = aws_subnet.public[0].id
  tags          = { 
    Name = "${var.ecs_cluster_name}-nat" 
  }
  depends_on    = [aws_internet_gateway.main]
}

#create public route table
resource "aws_route_table" "public" {
  vpc_id                = aws_vpc.main.id

  route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.ecs_cluster_name}-public"
  }
}

#create private route table
resource "aws_route_table" "private" {
  count  = var.enable_private_networking ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = { 
    Name = "${var.ecs_cluster_name}-private" 
  }
}


#create route table association for public route table
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#create route table association for private route table
resource "aws_route_table_association" "private" {
  count          = var.enable_private_networking ? var.private_subnet_count : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}