variable "azure_resource_identifier" {
  description = "Unique identifier for Azure resources"
  type        = string
}

variable "azure_location" {
  description = "Azure region location"
  type        = string
  default     = "eastus"
}


variable "azure_vm_size" {
  description = "Size of the Azure virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_os_profile_computer_name" {
  description = "OS Profile computer name"
  type        = string
  default     = "plugintest"
}

variable "azure_vm_admin_username" {
  description = "Admin username for the Azure virtual machine"
  type        = string
  default    = "plugintest"
}

variable "azure_vm_admin_password" {
  description = "Admin password for the Azure virtual machine"
  type        = string
  default     = "plugintestABC123@"
}

variable "azure_tf_state_bucket" {
  description = "Azure storage account name for Terraform state"
  type        = string
  default     = "bitopstfstate"
}
