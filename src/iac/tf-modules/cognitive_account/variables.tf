variable "service_name" {
  type        = string
  description = "Name of the service."
  default     = "dgs-s-cgs-oai003"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the target resource group."
  default     = "dgs-s-cgs-rg001"
}

variable "location" {
  type        = string
  description = "Location of the service"
  default     = "East US"
}

variable "sku" {
  type        = string
  description = "Service SKU."
  default     = "S0"
}
