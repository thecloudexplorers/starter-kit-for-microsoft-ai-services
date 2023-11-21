variable "name" {
  type        = string
  description = "Service name."
}

variable "location" {
  type        = string
  description = "Location of service."
}

variable "resource_group_name" {
  type        = string
  description = "Target reosurce group name."
}

variable "sku" {
  type        = string
  description = "Service SKU."
}
