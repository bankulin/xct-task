resource "aws_network_acl" "data_subnets_nacl" {
  vpc_id     = aws_vpc.xct_vpc.id
  subnet_ids = [aws_subnet.data_a_subnet.id, aws_subnet.data_b_subnet.id, aws_subnet.data_c_subnet.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.xct_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = aws_vpc.xct_vpc.ipv6_cidr_block
    from_port       = 0
    to_port         = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  egress {
    protocol        = "tcp"
    rule_no         = 400
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 32768
    to_port         = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol        = "tcp"
    rule_no         = 700
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 443
    to_port         = 443
  }

  egress {
    protocol   = "udp"
    rule_no    = 800
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  egress {
    protocol        = "udp"
    rule_no         = 900
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 53
    to_port         = 53
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.xct_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = aws_vpc.xct_vpc.ipv6_cidr_block
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = aws_vpc.xct_vpc.ipv6_cidr_block
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol        = "tcp"
    rule_no         = 400
    action          = "deny"
    ipv6_cidr_block = "::/0"
    from_port       = 1433
    to_port         = 1433
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  ingress {
    protocol        = "tcp"
    rule_no         = 600
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 32768
    to_port         = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 700
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  ingress {
    protocol        = "udp"
    rule_no         = 800
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 32768
    to_port         = 65535
  }

  tags = {
    Name = "xct-${var.environment}-data-subnets-nacl"
  }
}

resource "aws_network_acl" "private_subnets_nacl" {
  vpc_id     = aws_vpc.xct_vpc.id
  subnet_ids = [aws_subnet.private_a_subnet.id, aws_subnet.private_b_subnet.id, aws_subnet.private_c_subnet.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.xct_vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol        = "tcp"
    rule_no         = 300
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 1024
    to_port         = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol        = "udp"
    rule_no         = 500
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 1024
    to_port         = 65535
  }

  tags = {
    Name = "xct-${var.environment}-private-subnets-nacl"
  }
}

resource "aws_network_acl" "public_subnets_nacl" {
  vpc_id     = aws_vpc.xct_vpc.id
  subnet_ids = [aws_subnet.public_a_subnet.id, aws_subnet.public_b_subnet.id, aws_subnet.public_c_subnet.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }


  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol        = "-1"
    rule_no         = 200
    action          = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 0
    to_port         = 0
  }

  tags = {
    Name = "xct-${var.environment}-public-subnets-nacl"
  }
}
