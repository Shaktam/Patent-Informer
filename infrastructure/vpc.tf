resource "aws_vpc" "patent_vpc" {
    cidr_block  = "10.0.0.0/16"
    tags = {
        Name    = "Patent VPC"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id           = aws_vpc.patent_vpc.id
  cidr_block       = "10.0.1.0/24"
  availability_zone="us-west-2a"
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id           = aws_vpc.patent_vpc.id
  cidr_block       = "10.0.2.0/24"
  availability_zone="us-west-2b"
  tags = {
    Name     = "Public Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id           = aws_vpc.patent_vpc.id
  cidr_block       = "10.0.3.0/24"
  availability_zone="us-west-2a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id           = aws_vpc.patent_vpc.id
  cidr_block       = "10.0.4.0/24"
  availability_zone="us-west-2b"
  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id           = aws_vpc.patent_vpc.id
  
  tags = {
    Name = "Public Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.patent_vpc.id

  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "Public Route table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.private_subnet_a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = aws_vpc.patent_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table"
  }
}
