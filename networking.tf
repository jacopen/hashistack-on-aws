resource "aws_vpc" "main" {
  cidr_block         = "10.0.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = true

  tags = {
    Name = "jacopen"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "jacopen"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jacopen"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route" "hcp" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "172.25.16.0/20"
  vpc_peering_connection_id = "pcx-04088eb688186f248"
}
