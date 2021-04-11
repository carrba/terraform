data "azurerm_resource_group" "main" {
  name = var.rg
}

resource "azurerm_network_security_group" "main" {
  name                = "${substr(var.rg, 3, (length(var.rg)))}-RDPSecurityGroup"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  dynamic security_rule {
    for_each = var.nsg_rule
    content{
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}