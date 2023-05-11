resource "aws_subnet" "public_subnets" {
  count  = length(var.aws_zones)
  vpc_id = aws_vpc.vpc.id

  availability_zone = var.aws_zones[count.index]
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, count.index)

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_subnet_route_tables" {
  count  = length(var.aws_zones)
  vpc_id = aws_vpc.vpc.id

  // All instances in a public subnet can access the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_associations" {
  count = length(var.aws_zones)

  route_table_id = aws_route_table.public_subnet_route_tables[count.index].id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}
