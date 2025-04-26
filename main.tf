# --- root/main.tf ---

module "networking" {
  source       = "./networking"
}

module "compute" {
  source        = "./compute"
  web_sg        = module.networking.web_sg
  public_subnet = module.networking.public_subnet
}