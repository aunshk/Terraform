# security group for public ec2 instance
resource "aws_security_group" "public_sg" {
  name        = "${var.project}-public-sg"
  description = "Allow SSH from anywhere (for demo)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-public-sg"
  }
}


# security group fpr private ec2 instance
resource "aws_security_group" "private_sg" {
    name = "${var.project}-private-sg"
    description = "allow ssh from public ec2"
    vpc_id = var.vpc_id

ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    description = "ssh from laptop"
}    

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

tags = {
    Name= "${var.project}-private-sg"

}
}

# public ec2 instance
resource "aws_instance" "public_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.public_subnet_id
    vpc_security_group_ids = [aws_security_group.public_sg.id]
    associate_public_ip_address = true
    key_name = var.key_name


root_block_device {
    volume_size = 8 
    volume_type = "gp3"
}

tags = {
    Name = "${var.project}-public-ec2"
}
}

# private EC2 instance
resource "aws_instance" "private_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.private_subnet_id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    key_name = var.key_name


root_block_device {
    volume_size = 8
    volume_type = "gp3" 
}

tags = {
    Name = "${var.project}-private-ec2"
}
}