variable "pve_username" {
  type = string
  description = "The username of the user on the PVE host to authenticate with."
}

variable "pve_password" {
  type = string
  description = "The password of the user on the PVE host to authenticate with."
}

variable "pve_endpoint" {
  type = string
  description = "The endpoint of the PVE to connect to. Expressed as an IP Address."
}