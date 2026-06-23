variable "application_name" {
  type        = string
  description = "The name of the application for which resources are being deployed."
  default     = "homelab"
}

variable "environment" {
  type        = string
  description = "The environment in which the resources are being deployed."
  default     = "prod"
}

variable "owner" {
  type        = string
  description = "The owner of the resources being deployed."
  default     = "Mitchell Moore"
}

variable "location" {
  type        = string
  description = "The location in which the resources are being deployed."
  default     = "uksouth"
}

variable "tenant_id" {
  type        = string
  description = "The ID of the Azure tenant."
}

variable "global_settings" {
  type        = map(any)
  description = "A map of global settings that can be used to override default values for resources."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to add to the resource"
  default     = {}
}
