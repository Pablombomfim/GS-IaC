module "rede" {
    source = "./modules/rede"
}

module "compute" {
    source = "./modules/compute"
    id-sg = module.rede.id-sg
}