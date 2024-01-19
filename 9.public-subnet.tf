resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(var.args.vpc_cidr, local.availability_zones_count + 1, local.availability_zones_count)

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}
