 data "azurerm_resource_group" "test" {
   name     = var.azure_resource_identifier
  #  location = var.azure_location
  #  tags = local.azure_tags
 }

 resource "azurerm_virtual_network" "test" {
   name                = "${var.azure_resource_identifier}-vnet"
   address_space       = ["10.0.0.0/16"]
   location            = data.azurerm_resource_group.test.location
   resource_group_name = data.azurerm_resource_group.test.name
  #  tags = local.azure_tags
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
  #  tags = local.azure_tags
 }

 resource "azurerm_lb" "test" {
   name                = "${var.azure_resource_identifier}-LB"
   location            = data.azurerm_resource_group.test.location
   resource_group_name = data.azurerm_resource_group.test.name
  #  tags = local.azure_tags

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
  #  tags = local.azure_tags
 }

 resource "azurerm_managed_disk" "test" {
   count                = var.azure_vm_count
   name                 = "${var.azure_resource_identifier}-ManagedDisk-${count.index}"
   location             = data.azurerm_resource_group.test.location
   resource_group_name  = data.azurerm_resource_group.test.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
  #  tags = local.azure_tags
 }

 resource "azurerm_availability_set" "avset" {
   name                         = "${var.azure_resource_identifier}-AVSet"
   location                     = data.azurerm_resource_group.test.location
   resource_group_name          = data.azurerm_resource_group.test.name
   platform_fault_domain_count  = var.azure_vm_count
   platform_update_domain_count = var.azure_vm_count
   managed                      = true
  #  tags = local.azure_tags
 }

 resource "azurerm_virtual_machine" "test" {
   count                 = var.azure_vm_count
   name                  = "${var.azure_resource_identifier}-VM-${count.index}"
   location              = data.azurerm_resource_group.test.location
   availability_set_id   = azurerm_availability_set.avset.id
   resource_group_name   = data.azurerm_resource_group.test.name
   network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
   vm_size               = var.azure_vm_size

   # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

   storage_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "18.04-LTS"
     version   = "latest"
   }

   storage_os_disk {
     name              = "${var.azure_resource_identifier}-OSDisk-${count.index}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

   # Optional data disks
  #  storage_data_disk {
  #    name              = "datadisk_new_${count.index}"
  #    managed_disk_type = "Standard_LRS"
  #    create_option     = "Empty"
  #    lun               = 0
  #    disk_size_gb      = "1023"
  #  }

   storage_data_disk {
     name            = element(azurerm_managed_disk.test.*.name, count.index)
     managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
     create_option   = "Attach"
     lun             = 1
     disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
   }

   # TODO: pull from tfvars
   os_profile {
     computer_name  = var.azure_os_profile_computer_name
     admin_username = var.azure_vm_admin_username
     admin_password = var.azure_vm_admin_password
   }

   os_profile_linux_config {
     disable_password_authentication = false
   }

  #  tags = local.azure_tags
 }

 resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
