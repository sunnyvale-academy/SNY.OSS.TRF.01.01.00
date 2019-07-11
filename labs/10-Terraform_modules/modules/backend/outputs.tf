output "appservers_priv_ip_list" {
  value       = "${google_compute_instance.appserver.*.network_interface.0.network_ip}"
}