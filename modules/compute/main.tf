data "local_file" "index"{
  filename = "${path.root}/files/index.php"
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
    network = var.network #google_compute_network.web_network.name
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
    sed -i 's/{{DB_HOST}}/${var.db_host}/g' /var/www/html/index.php
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
    health_check      = var.health_check #google_compute_health_check.default.self_link
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