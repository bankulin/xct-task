resource "aws_route_table" "public" {
  depends_on = [aws_internet_gateway.gw]
  vpc_id     = aws_vpc.xct_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "xct-${var.environment}-public-rtb"
  }
}

resource "aws_route_table_association" "public_a_subnet" {
  subnet_id      = aws_subnet.public_a_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b_subnet" {
  subnet_id      = aws_subnet.public_b_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c_subnet" {
  subnet_id      = aws_subnet.public_c_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  depends_on = [aws_nat_gateway.nat_gw]
  vpc_id     = aws_vpc.xct_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }

  tags = {
    Name = "xct-${var.environment}-private-rtb"
  }
}

resource "aws_route_table_association" "private_a_subnet" {
  subnet_id      = aws_subnet.private_a_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b_subnet" {
  subnet_id      = aws_subnet.private_b_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c_subnet" {
  subnet_id      = aws_subnet.private_c_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "data" {
  depends_on = [aws_nat_gateway.nat_gw]
  vpc_id     = aws_vpc.xct_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.eigw.id
  }

  tags = {
    Name = "xct-${var.environment}-data-rtb"
  }
}

resource "aws_route_table_association" "data_a_subnet" {
  subnet_id      = aws_subnet.data_a_subnet.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_b_subnet" {
  subnet_id      = aws_subnet.data_b_subnet.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_c_subnet" {
  subnet_id      = aws_subnet.data_c_subnet.id
  route_table_id = aws_route_table.data.id
}
