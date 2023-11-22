module "rede" {
    source = "./modules/rede"
}

module "compute" {
    source = "./modules/compute"
    vpc_id = module.rede.vpc_id
    subnet_id = module.rede.subnet_id
}