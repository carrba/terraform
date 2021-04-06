data "azurerm_resource_group" "main" {
  name = var.rg
}

resource "azurerm_virtual_network" "main" {
  name                = "${substr(var.rg, 3, (length(var.rg)))}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

data "azurerm_network_security_group" "main" {
  name                = "${substr(var.rg, 3, (length(var.rg)))}-RDPSecurityGroup"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "internal-SecurityGroup" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = data.azurerm_network_security_group.main.id
}