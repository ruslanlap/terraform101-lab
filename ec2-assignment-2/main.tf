resource "aws_vpc" "vpc-assignment-2" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-dev"
  }
}

resource "aws_flow_log" "vpc-flow-log" {
  vpc_id          = aws_vpc.vpc-assignment-2.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
}

resource "aws_kms_key" "vpc_flow_log_key" {
  description             = "KMS key for VPC flow log encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.vpc_flow_log_key.arn
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" { #tfsec:ignore:aws-iam-no-policy-wildcards
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = [
        aws_cloudwatch_log_group.vpc_flow_log.arn,
        "${aws_cloudwatch_log_group.vpc_flow_log.arn}:*"
      ]
    }]
  })
}

resource "aws_subnet" "subnet-assignment-2" {
  vpc_id                  = aws_vpc.vpc-assignment-2.id
  cidr_block              = "10.123.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false #tfsec:ignore:aws-ec2-no-public-ip-subnet

  tags = {
    Name = "dev-subnet-public"
  }
}

resource "aws_eip" "dev_node_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "dev_node_eip_assoc" {
  instance_id   = aws_instance.dev_node.id
  allocation_id = aws_eip.dev_node_eip.id
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
    description = "SSH access from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description = "Allow all outbound traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
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

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 10
    encrypted   = true
  }

  tags = {
    Name = "dev-node"
  }
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = aws_eip.dev_node_eip.public_ip,
      user         = "ubuntu",
      Identityfile = "C:/Users/${var.user_name}/.ssh/aws"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}
