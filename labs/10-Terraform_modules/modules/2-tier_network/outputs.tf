output "public_subnet_ref" {
  value       = "${google_compute_subnetwork.public_subnet.self_link}"
}

output "private_subnet_ref" {
  value       = "${google_compute_subnetwork.private_subnet.self_link}"
}