resource "azurerm_cognitive_account" "this" {
  name                  = var.service_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = var.sku
}
