module "iam" {
  source = "./modules/iam"
}

module "network" {
  source = "./modules/network"
}

module "ec2" {
  source = "./modules/ec2"
  ami_id = var.ami_id
  instance_type = var.instance_type
  subnet_id = module.network.subnet_id
  security_group_id = module.network.security_group_id
  iam_instance_profile = module.iam.iam_instance_profile
}
