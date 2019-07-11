resource "google_compute_router" "router" {
  name    = "${var.VPC_NAME}-router"
  region  = "${var.REGION}"
  network = "${google_compute_network.vpc.self_link}"
}

resource "google_compute_router_nat" "nat-gw" {
  name                               = "${var.VPC_NAME}-nat-gw"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.REGION}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = "${google_compute_subnetwork.private_subnet.self_link}"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}