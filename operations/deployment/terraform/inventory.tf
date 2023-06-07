resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", "bitops-ssh-key.pem")
  file_permission = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl", {
    ip                       = azurerm_public_ip.test.ip_address
    ssh_keyfile              = local_sensitive_file.private_key.filename
    app_repo_name            = var.app_repo_name
    app_install_root         = var.app_install_root
    resource_identifier      = var.azure_resource_identifier
    application_mount_target = var.application_mount_target
    data_mount_target        = var.data_mount_target
  })
  filename = format("%s/%s", abspath(path.root), "inventory.yaml")
}