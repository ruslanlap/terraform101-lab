resource "aws_vpc" "vpc-assignment-2" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-dev"
  }
}
resource "aws_subnet" "subnet-assignment-2" {
  vpc_id                  = aws_vpc.vpc-assignment-2.id
  cidr_block              = "10.123.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-subnet-public"
  }
}
resource "aws_internet_gateway" "internet-gateway-assignment-2" {
  vpc_id = aws_vpc.vpc-assignment-2.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "route-table-assignment-2" {
  vpc_id = aws_vpc.vpc-assignment-2.id

  tags = {
    Name = "dev-route-table"
  }
}
resource "aws_route" "route-assignment-2" {
  route_table_id         = aws_route_table.route-table-assignment-2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway-assignment-2.id
}
resource "aws_route_table_association" "route-table-association-assignment-2" {
  subnet_id      = aws_subnet.subnet-assignment-2.id
  route_table_id = aws_route_table.route-table-assignment-2.id
}

resource "aws_security_group" "assignment-2-sg" {
  name        = "assignment-2-sg"
  description = "SG for assignment 2"
  vpc_id      = aws_vpc.vpc-assignment-2.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-assignment-2"
  }
}
resource "aws_key_pair" "aws_auth" {
  key_name   = "aws"
  public_key = file("~/.ssh/aws.pub")
}
resource "aws_instance" "dev_node" {
  ami                    = data.aws_ami.ubuntu-assignment-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.aws_auth.key_name
  vpc_security_group_ids = [aws_security_group.assignment-2-sg.id]
  subnet_id              = aws_subnet.subnet-assignment-2.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      Identityfile = "C:/Users/${var.user_name}/.ssh/aws"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}
