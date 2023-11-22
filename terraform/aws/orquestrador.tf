module "rede" {
    source = "./modules/rede"
}

module "compute" {
    source = "./modules/compute"
    id-sg = module.rede.id-sg
    subnet_id = module.rede.subnet_id
}