data "azurerm_resource_group" "main" {
  name = var.rg
}

resource "azurerm_network_security_group" "main" {
  name                = "${substr(var.rg, 3, (length(var.rg)))}-RDPSecurityGroup"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "${substr(var.rg, 3, (length(var.rg)))}-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["77.100.137.249/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${substr(var.rg, 3, (length(var.rg)))}-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["77.100.137.249/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${substr(var.rg, 3, (length(var.rg)))}-WinRM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefixes    = ["77.100.137.249/32"]
    destination_address_prefix = "*"
  }
}