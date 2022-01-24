# Module for network; This module will create all the neccessary resources for the entire project,
#such as vpc, subnets, gateways and all neccssary things to enable proper connectivity

module "network" {
  source                         = "./modules/network"
  region                         = var.region
  vpc_cidr                       = var.vpc_cidr
  subnet_cidr                    = var.subnet_cidr
  service_cidr                   = var.service_cidr
  all_ips                        = var.all_ips
  enable_dns_support             = var.enable_dns_support
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support
  resource_tag                   = var.resource_tag
}

# the module creates keypair
module "keypair" {
  source = "./modules/keypair"
}

# this module creates IAM role for master nodes
module "iam-master-nodes" {
  source = "./modules/iam-master-nodes"
}

# this module creates master-nodes
module "master-nodes" {
  source                      = "./modules/master-nodes"
  region                      = var.region
  subnet_id                   = module.network.subnet_id
  instance_type               = var.instance_type
  ami                         = var.ami
  k8s-sg                      = module.network.security-group
}


# this module creates IAM role for worker nodes
module "iam-worker-nodes" {
  source = "./modules/iam-worker-nodes"
}

# the module creates worker-nodes
module "worker-nodes" {
  source        = "./modules/worker-nodes"
  region        = var.region
  subnet_id     = module.network.subnet_id
  instance_type = var.instance_type
  ami           = var.ami
  k8s-sg        = module.network.security-group
}

# the module creates network load-balancer
module "network-lb" {
  source       = "./modules/network-lb"
  vpc_id       = module.network.vpc_id
  subnet_id    = module.network.subnet_id
  name_tag     = var.name_tag
}

# the module creates pod network routes
# module "pod-network-route" {
#   source               = "./modules/pod-network-route"
#   route_table          = module.network.route_table
#   route_table_id       = module.network.route_table_id
#   worker-0_instance_id = module.worker-nodes.instance_id_0
#   worker-1_instance_id = module.worker-nodes.instance_id_1
#   worker-2_instance_id = module.worker-nodes.instance_id_2
  

#   ////////////
#   # not part of code
#   # vpc_id               = module.network.vpc_id
#   # subnet_id            = module.network.subnet_id
#   # count        = length(var.pod_routes)
#   # pod_routes   = element(var.pod_routes, count.index)
#   # pod_routes = format("172.20.%d.0/24", count.index)
#   # instance_ids            = ""
#   # resource_tag         = var.resource_tag
# }