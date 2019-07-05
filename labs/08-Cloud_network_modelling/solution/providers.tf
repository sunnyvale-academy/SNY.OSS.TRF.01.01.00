// Terraform plugin for creating random ids
resource "random_id" "random_id" {
 byte_length = 8
}

// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.CREDENTIAL_FILE}")}"
 project     = "${var.PROJECT_ID}"
 region      = "${var.REGION}"
}