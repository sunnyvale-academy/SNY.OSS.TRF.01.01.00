variable "REGION" {
    default="us-west1"
}
variable "ZONE" {
    default="a"
}

variable "VM_USERNAME" {}

variable "WEBSERVER_IP" {}

variable "APPSERVERS_PRIV_IP_LIST" {}

variable "SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}


