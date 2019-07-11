variable "REGION" {
    default="us-west1"
}
variable "ZONE" {
    default="a"
}
variable "SSH_PUB_KEY_FILEPATH" {
    default="~/.ssh/id_rsa.pub"
}
variable "SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}

variable "INSTANCE_NAME" {
    default="be-appserver"
}

variable "PRIVATE_SUBNET_REF" {}

variable "IMAGE" {}

variable "VM_USERNAME" {}

variable "APPSERVERS_COUNT" {}