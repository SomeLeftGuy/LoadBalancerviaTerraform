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