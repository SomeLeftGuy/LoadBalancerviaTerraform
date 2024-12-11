variable "project_id" {
}
variable "region" {
  default = "europe-central-2"
}
variable "zone" {
  default = "europe-central-2a"
}
variable "db_user" {
  type        = string
  description = "Database user"
}
variable "db_password"{
  type        = string
  description = "Database password"
}
variable "db_name"{
  type        = string
  description = "Database name"
}
variable "authorized_networks" {
  description = "List of IP addresses authorized to connect to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Open to the world. Use carefully!
}