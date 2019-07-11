resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.VPC_NAME}-public-subnet"
  ip_cidr_range = "${var.PUBLIC_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.VPC_NAME}-private-subnet"
  ip_cidr_range = "${var.PRIVATE_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}