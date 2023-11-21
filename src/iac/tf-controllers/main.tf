
module "cognitive_services" {
  source                    = "../tf-modules/cognitive_account"
  service_name              = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku                       = var.sku
}
