# print the output of the public ip
output "vm_url" {
  value = azurerm_public_ip.test.ip_address
}

# print the output of the resource group
output "resource_group" {
  value = data.azurerm_resource_group.test.name
}

# print the vm name
output "vm_names" {
  value = azurerm_linux_virtual_machine.test.*.name
}

# print location
output "instance_location" {
  value = data.azurerm_resource_group.test.location
}
