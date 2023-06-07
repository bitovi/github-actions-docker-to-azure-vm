data "azurerm_resource_group" "test" {
  name     = var.azure_resource_identifier
  # location = var.azure_location
  # tags = local.azure_tags
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.azure_resource_identifier}-AVSet"
  location                     = data.azurerm_resource_group.test.location
  resource_group_name          = data.azurerm_resource_group.test.name
  platform_fault_domain_count  = var.azure_vm_count
  platform_update_domain_count = var.azure_vm_count
  managed                      = true
  # tags = local.azure_tags
}
