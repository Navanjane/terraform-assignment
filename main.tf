module "networking" {
  source              = "./networking"
  vpc_cidr_block      = "10.0.0.0/16"
  public1_name        = "tst"
  public_subnet_cidr  = ["10.0.20.0/24", "10.0.21.0/24"]
  private_subnet_cidr = ["10.0.10.0/24", "10.0.11.0/24"]
  subnet_id           = module.networking.public_subnet_id[0]
  instance_id         = module.ec2.instance_id
  availability_zones  = ["us-east-1a", "us-east-1b"]
  # subnet_id_lb = module.networking.private_subnet_id

}

module "ec2" {
  source                = "./ec2"
  ec2_subnet            = module.networking.private_subnet_id[0]
}