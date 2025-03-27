# PUBLIC SUBNETS
resource "aws_subnet" "public_a_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1a"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 0)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 0)
  tags = {
    Name                     = "public-a-subnet"
    "kubernetes.io/role/elb" = "1"
    type                     = "public"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "public_a_subnet_id" {
  name        = "/terraform/${local.module_name}/public-a-subnet-id"
  description = "The public A subnet ID"
  type        = "String"
  value       = aws_subnet.public_a_subnet.id
}

resource "aws_subnet" "public_b_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1b"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 1)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 1)
  tags = {
    Name                     = "public-b-subnet"
    "kubernetes.io/role/elb" = "1"
    type                     = "public"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "public_b_subnet_id" {
  name        = "/terraform/${local.module_name}/public-b-subnet-id"
  description = "The public B subnet ID"
  type        = "String"
  value       = aws_subnet.public_b_subnet.id
}

resource "aws_subnet" "public_c_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1c"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 2)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 2)
  tags = {
    Name                     = "public-c-subnet"
    "kubernetes.io/role/elb" = "1"
    type                     = "public"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "public_c_subnet_id" {
  name        = "/terraform/${local.module_name}/public-c-subnet-id"
  description = "The public C subnet ID"
  type        = "String"
  value       = aws_subnet.public_c_subnet.id
}

# PRIVATE SUBNETS
resource "aws_subnet" "private_a_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1a"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 4)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 4)
  tags = {
    Name                              = "private-a-subnet"
    "kubernetes.io/role/internal-elb" = "1"
    type                              = "private"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "private_a_subnet_id" {
  name        = "/terraform/${local.module_name}/private-a-subnet-id"
  description = "The private A subnet ID"
  type        = "String"
  value       = aws_subnet.private_a_subnet.id
}

resource "aws_subnet" "private_b_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1b"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 5)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 5)
  tags = {
    Name                              = "private-b-subnet"
    "kubernetes.io/role/internal-elb" = "1"
    type                              = "private"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "private_b_subnet_id" {
  name        = "/terraform/${local.module_name}/private-b-subnet-id"
  description = "The private B subnet ID"
  type        = "String"
  value       = aws_subnet.private_b_subnet.id
}

resource "aws_subnet" "private_c_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1c"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 6)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 6)
  tags = {
    Name                              = "private-c-subnet"
    "kubernetes.io/role/internal-elb" = "1"
    type                              = "private"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "private_c_subnet_id" {
  name        = "/terraform/${local.module_name}/private-c-subnet-id"
  description = "The private C subnet ID"
  type        = "String"
  value       = aws_subnet.private_c_subnet.id
}

# DATA SUBNETS

resource "aws_subnet" "data_a_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1a"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 8)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 8)
  tags = {
    Name = "data-a-subnet"
    type = "data"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "data_a_subnet_id" {
  name        = "/terraform/${local.module_name}/data-a-subnet-id"
  description = "The data A subnet ID"
  type        = "String"
  value       = aws_subnet.data_a_subnet.id
}

resource "aws_subnet" "data_b_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1b"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 9)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 9)
  tags = {
    Name = "data-b-subnet"
    type = "data"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "data_b_subnet_id" {
  name        = "/terraform/${local.module_name}/data-b-subnet-id"
  description = "The data B subnet ID"
  type        = "String"
  value       = aws_subnet.data_b_subnet.id
}

resource "aws_subnet" "data_c_subnet" {
  assign_ipv6_address_on_creation = true
  availability_zone               = "eu-west-1c"
  cidr_block                      = cidrsubnet(aws_vpc.xct_vpc.cidr_block, 5, 10)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.xct_vpc.ipv6_cidr_block, 8, 10)
  tags = {
    Name = "data-c-subnet"
    type = "data"
  }
  vpc_id = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "data_c_subnet_id" {
  name        = "/terraform/${local.module_name}/data-c-subnet-id"
  description = "The data C subnet ID"
  type        = "String"
  value       = aws_subnet.data_c_subnet.id
}
