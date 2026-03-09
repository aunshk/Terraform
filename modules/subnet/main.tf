resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "${var.project}-private-subnet"
  }
}

# -----------------------------
# PUBLIC ROUTE TABLE
# -----------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------
# PRIVATE ROUTE TABLE
# -----------------------------

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}