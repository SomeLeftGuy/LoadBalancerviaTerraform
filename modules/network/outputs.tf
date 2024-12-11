output "lb_public_ip" {
  value = "Load Balancer public IP = ${google_compute_global_address.default.address}"
}
output "health_check" {
  value = google_compute_health_check.default.self_link
}
output "network" {
  value = google_compute_network.web_network.name
}