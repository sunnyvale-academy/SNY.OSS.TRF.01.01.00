variable "REGION" {
    default="us-west1"
}
variable "ZONE" {
    default="a"
}

variable "VM_USERNAME" {}

variable "APPSERVERS_COUNT" {}

variable "APPSERVERS_PRIV_IP_LIST" {}

variable "SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}

variable "BASTION_SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}

variable "BASTION_VM_USERNAME" {}

variable "BASTION_HOST_IP" {}


variable "APP_DIRPATH" {}