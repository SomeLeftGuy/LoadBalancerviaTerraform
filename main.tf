# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
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
module "compute" {
  source = "./modules/compute"
  network = module.network.network
  nodes = var.nodes
  db_host = module.database.sql_ip
  health_check = module.network.health_check
}

module "network" {
  source = "./modules/network"
  instance_group = module.compute.instance_group
}


module "database" {
  source = "./modules/database"
  project_id = var.project_id
  db_name = var.db_name
  db_password = var.db_password
  db_user = var.db_user
}
