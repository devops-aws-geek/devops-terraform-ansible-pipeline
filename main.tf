# --- root/main.tf ---

module "networking" {
  source       = "./networking"
  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_cidrs
}

module "compute" {
  source        = "./compute"
  web_sg        = module.networking.web_sg
  public_subnet = module.networking.public_subnet
}