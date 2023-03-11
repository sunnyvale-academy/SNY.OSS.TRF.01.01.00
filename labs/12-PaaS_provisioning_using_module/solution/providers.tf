provider "google" {
    version     = "2.18.0"
    credentials = "${file("${var.credentials}")}"
    project     = "${var.project_id}"
    region      = "${var.region}"
}

provider "google-beta" {
    version     = "2.18.0"
    credentials = "${file("${var.credentials}")}"
    project     = "${var.project_id}"
    region      = "${var.region}"
}