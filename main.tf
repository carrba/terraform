provider "azurerm" {
  features{}
}

data "azurerm_resource_group" "main" {
  name = "RG-${var.prefix}"
}

data "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = data.azurerm_virtual_network.main.name
}

module "vm" {
  source               = "./vm"
  prefix               = var.prefix
  RG_name              = data.azurerm_resource_group.main.name
  RG_location          = data.azurerm_resource_group.main.location
  computer_name        = var.computer_name
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  Security_Group_ID    = data.azurerm_network_security_group.main.id
  virtual_network_ID   = data.azurerm_virtual_network.main.id
  virtual_network_name = data.azurerm_virtual_network.main.name
  subnet_ID            = data.azurerm_subnet.internal.id
  publisher            = var.publisher
  offer                = var.offer
  sku                  = var.sku
  data_disk_size       = var.data_disk_size
  vm_size              = var.vm_size
  private_ip           = var.private_ip
  dns                  = var.dns
  puppet_client        = var.puppet_client
}

data "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-RDPSecurityGroup"
  resource_group_name = data.azurerm_resource_group.main.name
}