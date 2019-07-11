variable "REGION" {
    default="us-west1"
}
variable "ZONE" {
    default="a"
}
variable "CREDENTIAL_FILE" {}
variable "VM_USERNAME" {}
variable "PROJECT_ID" {}


variable "IMAGE" {
    default="debian-cloud/debian-9"
}

variable "SSH_PUB_KEY_FILEPATH" {
    default="~/.ssh/id_rsa.pub"
}

variable "SSH_PRIV_KEY_FILEPATH" {
    default="~/.ssh/id_rsa"
}
