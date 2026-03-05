# Create the aws provide code. Find help at - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# Set the region to eu-central-1

provider "aws" {
  region = "eu-central-1"
}

#Create the EC2 instance resource code. Find help at - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "terraform-test" {
  ami           = "ami-0c42fad2ea005202d"
  instance_type = "t2.micro"
  tags = {
    Name        = "terraform-assignment-1"
    environment = "Dev"
  }
}
