aws_region = "eu-north-1"

project = "terraform-vpc-demo"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

instance_type = "t3.micro"
ami_id        = "ami-0fa91bc90632c73c9"
key_name      = "awskey"