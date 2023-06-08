resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", "bitops-ssh-key.pem")
  file_permission = "0600"
}

# create public key from private key
resource "azurerm_ssh_public_key" "key" {
  name = "bitops-ssh-pub-key"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  public_key = tls_private_key.key.public_key_openssh
}
