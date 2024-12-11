# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
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
    ports    = ["80"]
  }
  allow{
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create an instance template
# Replace with your Cloud SQL instance connection name
variable "cloud_sql_connection_name" {
  default = "34.118.105.244"
}

# Instance Template with Cloud SQL Proxy
# Replace with your Cloud SQL public IP
variable "cloud_sql_public_ip" {
  default = "34.118.105.244"
}

# Replace with your Cloud SQL database credentials
variable "cloud_sql_db_user" {
  default = "admin"
}

variable "cloud_sql_db_password" {
  default = "admin"
}

variable "cloud_sql_db_name" {
  default = "demo"
}
data "local_file" "index"{
  filename = "${path.module}/files/index.php"
}
# Instance Template with direct Cloud SQL connection
resource "google_compute_instance_template" "web_template" {
  name_prefix        = "web-template-"
  machine_type  = "e2-medium"
  can_ip_forward = false

  tags = ["http-server"]

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
  }

  network_interface {
    network = google_compute_network.web_network.name
    access_config {}
  }
  lifecycle {
    create_before_destroy = true
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y php
    apt-get install -y php-mysqli
    apt-get install -y apache2 
    rm /var/www/html/index.html
    echo '${data.local_file.index.content}' > /var/www/html/index.php
    sed -i 's/{{DB_HOST}}/${google_sql_database_instance.default.public_ip_address}/g' /var/www/html/index.php
    systemctl enable apache2
    systemctl start apache2
    systemctl restart apache2
  EOT
}

# Create a Managed Instance Group (MIG)
resource "google_compute_region_instance_group_manager" "web_mig" {
  name                = "web-mig"
  base_instance_name  = "web"
  target_size         = var.nodes
  region              = "europe-central2"
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.self_link
    initial_delay_sec = 300  # Time in seconds to wait before auto-healing
  }
  update_policy{
    type                           = "PROACTIVE"
    instance_redistribution_type   = "NONE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 0
    replacement_method             = "RECREATE"
    max_unavailable_fixed          = var.nodes
  }
}

# Create a health check
resource "google_compute_health_check" "default" {
  name = "basic-health-check"

  http_health_check {
    request_path = "/"
    port         = 80
  }
}

# Create a global HTTP load balancer
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
    group = google_compute_region_instance_group_manager.web_mig.instance_group
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
resource "google_sql_database_instance" "default" {
  name             = "example-database"
  project          = var.project_id
  region           = var.region
  database_version = "MYSQL_8_0"
  deletion_protection = false
  settings {
    tier = "db-f1-micro"  # Change tier for production use

    ip_configuration {
      ipv4_enabled    = true
      dynamic authorized_networks { 
        for_each = var.authorized_networks 
        iterator = net
        content {
          name = "value"
          value = net.value
        }
      }
    }
  }
}

# Create Database
resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
  project  = var.project_id
}

# Create Database User
resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
  project  = var.project_id
}
output "lb_public_ip" {
  value = google_compute_global_address.default.address
}