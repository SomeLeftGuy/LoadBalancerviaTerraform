output "lb_public_ip" {
  value = module.network.lb_public_ip
}
output "nodes" {
  value = module.compute.nodes
}