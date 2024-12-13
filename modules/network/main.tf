resource "google_compute_global_address" "default" {
  name = "web-lb-ip"
}

resource "google_compute_backend_service" "default" {
  name                  = "web-backend"
  port_name             = "http"
  protocol              = "HTTP"
  health_checks         = [google_compute_health_check.default.self_link]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = var.instance_group#google_compute_region_instance_group_manager.web_mig.instance_group
  }
}

resource "google_compute_url_map" "default" {
  name            = "web-url-map" 
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name   = "web-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "web-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_http_proxy.default.self_link
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
}
resource "google_compute_health_check" "default" {
  name = "basic-health-check"

  http_health_check {
    request_path = "/"
    port         = 80
  }
}
# Create a VPC network
resource "google_compute_network" "web_network" {
  name = "app-network"
}

# Create a firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.web_network.name

  allow {
    protocol = "tcp"
    ports    = ["80, 443"]
  }


  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-http"
  network = google_compute_network.web_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }


  source_ranges = ["<Company Ip addresses>"]
}