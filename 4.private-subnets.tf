resource "aws_subnet" "private_subnets" {
  count = length(local.availability_zones)

  vpc_id            = aws_vpc.this.id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = cidrsubnet(local.vpc_cidr, local.subnet_count, count.index)

  tags = {
    format("kubernetes.io/cluster/%v", local.cluster_name) = "shared"
  }

  depends_on = [aws_nat_gateway.this]
}

resource "aws_route_table" "private_subnet_route_tables" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private_subnet_route_table_associations" {
  count = length(local.availability_zones)

  route_table_id = aws_route_table.private_subnet_route_tables[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}
