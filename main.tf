module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    project = var.project_name
}

module "subnet" {
    source = "./modules/subnet"
    vpc_id = module.vpc.vpc_id
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    igw_id = module.vpc.igw_id
    project = var.project_name
}

module "ec2" {
    source = "./modules/ec2"
    vpc_id = module.vpc.vpc_id
    public_subnet_id = module.subnet.public_subnet_id
    private_subnet_id = module.subnet.private_subnet_id
    instance_type = var.instance_type
    ami_id = var.ami_id
    key_name = var.key_name
    project = var.project_name
}

