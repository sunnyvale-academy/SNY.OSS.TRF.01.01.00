module "vpc" {
  source = "../modules/2-tier_network"
  VPC_NAME = "denis"
  PUBLIC_SUBNET_CDIR = "192.168.1.0/24"
  PRIVATE_SUBNET_CDIR = "192.168.2.0/24"
}

module "frontend" {
  source = "../modules/frontend"
  INSTANCE_NAME = "denis-fe-loadbalancer"
  SSH_PUB_KEY_FILEPATH = "~/.ssh/id_rsa.pub"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from vpc module output
  PUBLIC_SUBNET_REF = "${module.vpc.public_subnet_ref}"
  VM_USERNAME = "${var.VM_USERNAME}"
  IMAGE = "${var.IMAGE}"
}


module "backend" {
  source = "../modules/backend"
  INSTANCE_NAME = "denis-be-appserver"
  SSH_PUB_KEY_FILEPATH = "~/.ssh/id_rsa.pub"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from vpc module output
  PRIVATE_SUBNET_REF = "${module.vpc.private_subnet_ref}"
  VM_USERNAME = "${var.VM_USERNAME}"
  IMAGE = "${var.IMAGE}"
  APPSERVERS_COUNT = "3"
}

module "application" {
  source = "../modules/application"
  // taken from backend module output 
  APPSERVERS_PRIV_IP_LIST = "${module.backend.appservers_priv_ip_list}"
  VM_USERNAME = "${var.VM_USERNAME}"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  BASTION_VM_USERNAME = "${var.VM_USERNAME}"
  BASTION_SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  // taken from frontend module output
  BASTION_HOST_IP = "${module.frontend.webserver-ip}"
  APP_DIRPATH = "../app/"
  // taken from backend module output 
  APPSERVERS_COUNT = "${module.backend.appservers_count}"
}


module "cluster" {
  source = "../modules/cluster"
  // taken from backend module output 
  APPSERVERS_PRIV_IP_LIST = "${module.backend.appservers_priv_ip_list}"
  VM_USERNAME = "${var.VM_USERNAME}"
  // taken from frontend module output 
  WEBSERVER_IP = "${module.frontend.webserver-ip}"
  SSH_PRIV_KEY_FILEPATH = "~/.ssh/id_rsa"
  NGINX_TEMPLATE_FILEPATH = "../templates/nginx.conf.tmpl"
  // taken from backend module output 
  APPSERVERS_COUNT = "${module.backend.appservers_count}"
}
