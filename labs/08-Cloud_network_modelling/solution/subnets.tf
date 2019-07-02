resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet-${random_id.random_id.hex}"
  ip_cidr_range = "${var.PUBLIC_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-${random_id.random_id.hex}"
  ip_cidr_range = "${var.PRIVATE_SUBNET_CDIR}"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "${var.REGION}"
}