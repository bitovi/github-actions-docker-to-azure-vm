variable "azure_resource_identifier" {
  description = "Unique identifier for Azure resources"
  type        = string
}

variable "azure_location" {
  description = "Azure region location"
  type        = string
  default     = "eastus"
}

variable "azure_vm_count" {
  description = "Number of Azure virtual machines to create"
  type        = number
  default     = 1
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

variable "app_repo_name" {
  type        = string
  description = "GitHub Repo Name"
}

variable "app_install_root" {
  type        = string
  description = "Path on the instance where the app will be cloned (do not include app_repo_name)."
  default     = "/home/ubuntu"
}

variable "application_mount_target" {
  type        = string
  description = "Directory path in application env to mount directory"
  default = "data"
}

variable "data_mount_target" {
  type        = string
  description = "Directory path in efs to mount to"
  default     = "/data"
}

variable "ops_repo_environment" {
  type        = string
  description = "Ops Repo Environment (i.e. directory name)"
}

variable "app_org_name" {
  type        = string
  description = "GitHub Org Name"
}

variable "app_branch_name" {
  type        = string
  description = "GitHub Branch Name"
}
