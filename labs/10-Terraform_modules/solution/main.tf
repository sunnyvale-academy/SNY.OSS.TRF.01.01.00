module "vpc" {
  source = "./modules/2-tier_network"
  VPC_NAME = "denis"
  PUBLIC_SUBNET_CDIR = "192.168.1.0/24"
  PRIVATE_SUBNET_CDIR = "192.168.2.0/24"
}

module "frontend" {
  source = "./modules/frontend"
  INSTANCE_NAME = "denis-fe-loadbalancer"
  SSH_PUB_KEY_FILEPATH = "~/.ssh/id_rsa.pub"
}
