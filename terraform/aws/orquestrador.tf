module "rede" {
  source = "./modules/rede"
}

module "compute" {
  source    = "./modules/compute"
  id-sg     = module.rede.security_groups-id
  subnet_id = module.rede.subnet_id
}
