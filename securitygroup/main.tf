provider "azurerm" {
  features{}
}

data "azurerm_resource_group" "main" {
  name     = "RG-${var.prefix}"
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-RDPSecurityGroup"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "${var.prefix}-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["82.45.59.63/32","89.250.46.11/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.prefix}-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["82.45.59.63/32","89.250.46.11/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.prefix}-WinRM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefixes    = ["82.45.59.63/32","89.250.46.11/32"]
    destination_address_prefix = "*"
  }

  security_rule {
    name		       = "${var.prefix}-Splunk"
    priority		       = 125
    direction		       = "inbound"
    access		       = "Allow"
    protocol		       = "Tcp"
    source_port_range	       = "*"
    destination_port_range     = "8000"
    source_address_prefixes    = ["82.45.59.63/32","89.250.46.11/32"]
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "${var.prefix}-internal"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["10.0.0.0/24"]
    destination_address_prefix = "*"
  }
}
