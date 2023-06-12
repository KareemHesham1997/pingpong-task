#VPC
resource "aws_vpc" "kareem-vpc" {
  cidr_block         = "10.0.0.0/16"
  tags = {
    Name = "kareem-vpc"
  }
}

#Subnets
resource "aws_subnet" "public-sub-1" {
  vpc_id     = aws_vpc.kareem-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public subnet 1"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/my-eks" = "owned"
  }
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public-sub-2" {
  vpc_id     = aws_vpc.kareem-vpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public subnet 2"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/my-eks" = "owned"
  }
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private-sub1" {
  vpc_id     = aws_vpc.kareem-vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "private subnet 1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/my-eks" = "owned"
  }
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private-sub2" {
  vpc_id     = aws_vpc.kareem-vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    "Name" = "private subnet 2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/my-eks" = "owned"
   }
   availability_zone = "us-east-1b"
}

#igw & ngw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kareem-vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_ip" {
  vpc = true
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public-sub-1.id
}

#Route
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kareem-vpc.id
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public-sub-1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public-sub-2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kareem-vpc.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private-sub1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private-sub2.id
  route_table_id = aws_route_table.private.id
}

#Secgroup
resource "aws_security_group" "secgroup" {
  name        = "secgroup"
  description = "Allow HTTP traffic from anywhere"
  vpc_id = aws_vpc.kareem-vpc.id
  tags = {
    Name = "secgroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}