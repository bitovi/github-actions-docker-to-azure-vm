resource "azurerm_linux_virtual_machine" "test" {
  count                 = var.azure_vm_count
  name                  = "${var.azure_resource_identifier}-VM-${count.index}"
  location              = data.azurerm_resource_group.test.location
  # availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = data.azurerm_resource_group.test.name
  size               = var.azure_vm_size

  admin_username = var.azure_vm_admin_username
  admin_password = var.azure_vm_admin_password
  disable_password_authentication = false
  
  computer_name  = var.azure_os_profile_computer_name

  network_interface_ids = [
    azurerm_network_interface.public[count.index].id
    # azurerm_network_interface.internal[count.index].id
  ]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.azure_resource_identifier}-OSDisk-${count.index}"
    caching              = "ReadWrite"
    # create_option        = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  # Optional data disks
#  storage_data_disk {
#    name              = "datadisk_new_${count.index}"
#    managed_disk_type = "Standard_LRS"
#    create_option     = "Empty"
#    lun               = 0
#    disk_size_gb      = "1023"
#  }

  # storage_data_disk {
  #   name            = element(azurerm_managed_disk.test.*.name, count.index)
  #   managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
  #   create_option   = "Attach"
  #   lun             = 1
  #   disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
  # }

  # TODO: pull from tfvars
  # os_profile {
  #   computer_name  = var.azure_os_profile_computer_name
  #   admin_username = var.azure_vm_admin_username
  #   admin_password = var.azure_vm_admin_password
  # }

  # os_profile_linux_config {
  #   disable_password_authentication = false
  # }

  #  tags = local.azure_tags
 }

# resource "azurerm_managed_disk" "test" {
#   count                = var.azure_vm_count
#   name                 = "${var.azure_resource_identifier}-ManagedDisk-${count.index}"
#   location             = data.azurerm_resource_group.test.location
#   resource_group_name  = data.azurerm_resource_group.test.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "1023"
#   #  tags = local.azure_tags
# }
