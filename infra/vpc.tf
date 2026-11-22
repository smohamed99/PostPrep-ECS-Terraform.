data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# netnum 0 and 1 -> 10.0.0.0/25 and 10.0.0.128/25
# newbits of 3 adds 3 to the prefix (22 + 3 = 25) and divides the VPC
# into 2^3 = 8 blocks. These take the first two.
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "public"
  }
}

# netnum 2 and 3 -> 10.0.1.0/25 and 10.0.1.128/25
# No map_public_ip_on_launch - these must not hand out public addresses.
resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "private"
  }
}

# One Elastic IP per AZ the regional NAT gateway will cover.
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# A single regional NAT gateway covering both AZs, in manual mode.
# Manual means the AZs are declared up front rather than discovered -
# no 15 to 60 minute expansion wait after each rebuild, and no traffic
# crossing an AZ boundary to reach a gateway that hasn't expanded yet.
resource "aws_nat_gateway" "main" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
  connectivity_type = "public"

  availability_zone_address {
    availability_zone = data.aws_availability_zones.available.names[0]
    allocation_ids    = [aws_eip.nat[0].id]
  }

  availability_zone_address {
    availability_zone = data.aws_availability_zones.available.names[1]
    allocation_ids    = [aws_eip.nat[1].id]
  }

  tags = {
    Name = "${var.project_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# One private route table, because one regional NAT serves both AZs.
# Zonal NATs would need one table per AZ, each pointing at its own.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Without these, subnets silently fall back to the VPC main route table.
resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}