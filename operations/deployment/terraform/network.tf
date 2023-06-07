resource "azurerm_virtual_network" "test" {
  name                = "${var.azure_resource_identifier}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name
  # tags = local.azure_tags
}

resource "azurerm_subnet" "test" {
  name                 = "${var.azure_resource_identifier}-subnet"
  resource_group_name  = data.azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                         = "${var.azure_resource_identifier}-publicIPForLB"
  location                     = data.azurerm_resource_group.test.location
  resource_group_name          = data.azurerm_resource_group.test.name
  allocation_method            = "Static"
  # tags = local.azure_tags
}

resource "azurerm_lb" "test" {
  name                = "${var.azure_resource_identifier}-LB"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name
  # tags = local.azure_tags

  frontend_ip_configuration {
    name                 = "${var.azure_resource_identifier}-publicIPAddress"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id     = azurerm_lb.test.id
  name                = "${var.azure_resource_identifier}-BEPool"
}

resource "azurerm_network_interface" "test" {
  count               = var.azure_vm_count
  name                = "${var.azure_resource_identifier}-NIC-${count.index}"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "${var.azure_resource_identifier}-IPcfg-${count.index}"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
  # tags = local.azure_tags
}
