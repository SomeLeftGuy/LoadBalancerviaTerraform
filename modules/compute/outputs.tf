output "nodes" {
  value = "There will be ${var.nodes} nodes."
}
output "instance_group" {
  value = google_compute_region_instance_group_manager.web_mig.instance_group
}