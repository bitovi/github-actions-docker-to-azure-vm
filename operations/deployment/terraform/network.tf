resource "azurerm_virtual_network" "test" {
  name                = "${var.azure_resource_identifier}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name
  # tags = local.azure_tags
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.azure_resource_identifier}-subnet"
  resource_group_name  = data.azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "public" {
  count               = var.azure_vm_count
  name                = "${var.azure_resource_identifier}-NIC-PUB-${count.index}"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "${var.azure_resource_identifier}-IPcfg-${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }

  lifecycle {
    create_before_destroy = true
  }
  # tags = local.azure_tags
}
# resource "azurerm_network_interface" "internal" {
#   count               = var.azure_vm_count
#   name                = "${var.azure_resource_identifier}-NIC-INT-${count.index}"
#   location            = data.azurerm_resource_group.test.location
#   resource_group_name = data.azurerm_resource_group.test.name

#   ip_configuration {
#     name                          = "${var.azure_resource_identifier}-IPcfg-${count.index}"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
#   # tags = local.azure_tags
# }

resource "azurerm_public_ip" "test" {
  name                         = "${var.azure_resource_identifier}-publicIP"
  location                     = data.azurerm_resource_group.test.location
  resource_group_name          = data.azurerm_resource_group.test.name
  allocation_method            = "Dynamic"
  # tags = local.azure_tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "nsg_ssh_vm"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name
  security_rule {
    name                       = "ssh"
    priority                   = 1001
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.public[0].private_ip_address
  }
}

# resource "azurerm_network_interface_security_group_association" "main" {
#   count                     = var.azure_vm_count
#   network_interface_id      = azurerm_network_interface.internal[count.index].id
#   network_security_group_id = azurerm_network_security_group.vm.id
# }


# resource "azurerm_lb" "test" {
#   name                = "${var.azure_resource_identifier}-LB"
#   location            = data.azurerm_resource_group.test.location
#   resource_group_name = data.azurerm_resource_group.test.name
#   # tags = local.azure_tags

#   frontend_ip_configuration {
#     name                 = "${var.azure_resource_identifier}-publicIPAddress"
#     public_ip_address_id = azurerm_public_ip.test.id
#   }
# }

# resource "azurerm_lb_backend_address_pool" "test" {
#   loadbalancer_id     = azurerm_lb.test.id
#   name                = "${var.azure_resource_identifier}-BEPool"
# }


