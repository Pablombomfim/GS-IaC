module "rede" {
    source = "./modules/rede"
}

module "compute" {
    source = "./modules/compute"
    vpc_id = modules.rede.vpc_id
    subnet_id = modules.rede.subnet_id
}