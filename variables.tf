
variable "db_user" {
  type        = string
  description = "Database user"
  default     = "admin"
}
variable "db_password"{
  type        = string
  description = "Database password"
  default     = "admin"
}
variable "db_name"{
  type        = string
  description = "Database name"
  default     = "demo"
}
variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
  default     = "bsuir-project-439420"
}

variable "region" {
  type        = string
  description = "The Compute Region to deploy to"
  default     = "europe-central2"
}

variable "zone" {
  type        = string
  description = "The Compute Zone to deploy to"
  default     = "europe-central2-a"
}

variable "nodes" {
  type        = number
  description = "The number of nodes in the managed instance group"
  default     = 3
}
variable "authorized_networks" {
  description = "List of IP addresses authorized to connect to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Open to the world. Use carefully!
}