resource "aws_vpc" "lambda-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-lambda-vpc"
    },
  )

}

resource "aws_subnet" "lambda-vpc-subnet_public" {
  vpc_id                  = aws_vpc.lambda-vpc.id
  cidr_block              = "10.0.0.0/19"
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-lambda-vpc-subnet-public"
    },
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.lambda-vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-internet-gateway"
    },
  )
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.lambda-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-route-table-public"
    },
  )
}

resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.lambda-vpc-subnet_public.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-eip"
    },
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.lambda-vpc-subnet_public.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-nat-gateway"
    },
  )
}

resource "aws_subnet" "lambda-vpc-subnet-private" {
  cidr_block              = "10.0.32.0/20"
  vpc_id                  = aws_vpc.lambda-vpc.id
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-lambda-vpc-subnet-private"
    },
  )
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.lambda-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-route-table-private"
    },
  )
}

resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.lambda-vpc-subnet-private.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.lambda-vpc.default_network_acl_id
  subnet_ids             = [aws_subnet.lambda-vpc-subnet_public.id, aws_subnet.lambda-vpc-subnet-private.id]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-default-network-acl"
    },
  )
}
resource "aws_security_group" "lambda-vpc-sg" {
  name_prefix = "lambda-vpc-sg"
  vpc_id      = aws_vpc.lambda-vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-default-security-group"
    },
  )
}
