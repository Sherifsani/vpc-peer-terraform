resource "aws_vpc" "vpc-a" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "vpc-a"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.vpc-a.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "subnet_a"
  }
}

resource "aws_internet_gateway" "igw-a" {
  vpc_id = aws_vpc.vpc-a.id

  tags = {
    Name = "igw-a"
  }
}

resource "aws_route_table" "rtb-a" {
  vpc_id = aws_vpc.vpc-a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-a.id
  }

  tags = {
    Name = "rtb-a"
  }
}

resource "aws_route_table_association" "assoc-a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rtb-a.id
}

resource "aws_security_group" "allow_ssh_a" {
  vpc_id      = aws_vpc.vpc-a.id
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22 # Allows inbound traffic on port 22 (SSH)
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP ping"
    from_port   = -1 # Allows all ICMP types (ping requests and replies)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server_a" {
  subnet_id                   = aws_subnet.subnet_a.id
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  key_name                    = "id_rsa"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_a.id]

  tags = {
    Name = "server-a"
  }
}

resource "aws_vpc" "vpc-b" {
  cidr_block           = "20.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-b"
  }
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = aws_vpc.vpc-b.id
  cidr_block        = "20.0.1.0/24"
  availability_zone = "us-east-1b"
  # map_public_ip_on_launch = true

  tags = {
    Name = "subnet-b"
  }
}

# resource "aws_internet_gateway" "igw-b" {
#   vpc_id = aws_vpc.vpc-b.id

#   tags = {
#     Name = "igw-b"
#   }
# }

# resource "aws_route_table" "rtb-b" {
#   vpc_id = aws_vpc.vpc-b.id

#   route = {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw-b.id
#   }

#   tags = {
#     Name = "rtb-b"
#   }
# }

# resource "aws_route_table_association" "assoc-b" {
#   subnet_id      = aws_subnet.subnet-b.id
#   route_table_id = aws_route_table.rtb-b.id

# }

resource "aws_security_group" "allow_ssh_b" {
  vpc_id      = aws_vpc.vpc-b.id
  description = "Allow SSH inbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "Allow ICMP ping"
    from_port       = -1 # Allows all ICMP types (ping requests and replies)
    to_port         = -1
    protocol        = "icmp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.allow_ssh_a.id]
  }

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

resource "aws_instance" "server_b" {
  subnet_id                   = aws_subnet.subnet-b.id
  ami                         = "ami-0866a3c8686eaeeba"
  instance_type               = "t2.micro"
  key_name                    = "id_rsa"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_b.id]

  tags = {
    Name = "server-b"
  }


}

resource "aws_vpc_peering_connection" "vpc-peer" {
  auto_accept = true
  vpc_id      = aws_vpc.vpc-a.id
  peer_vpc_id = aws_vpc.vpc-b.id

  tags = {
    Name = "vpc-peer"
  }
}

resource "aws_route" "route_to_vpc_b" {
  route_table_id            = aws_route_table.rtb-a.id
  destination_cidr_block    = aws_vpc.vpc-b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peer.id
}

resource "aws_route_table" "rtb-b" {
  vpc_id = aws_vpc.vpc-b.id

  tags = {
    Name = "rtb-b"
  }
}
resource "aws_route_table_association" "assoc-b" {
  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.rtb-b.id
}

resource "aws_route" "route_to_vpc_a" {
  route_table_id            = aws_route_table.rtb-b.id
  destination_cidr_block    = aws_vpc.vpc-a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peer.id
}
resource "aws_security_group_rule" "allow_icmp_from_vpc_b" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.allow_ssh_a.id
  cidr_blocks       = [aws_vpc.vpc-b.cidr_block]
}

resource "aws_security_group_rule" "allow_icmp_from_vpc_a" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.allow_ssh_b.id
  cidr_blocks       = [aws_vpc.vpc-a.cidr_block]
}