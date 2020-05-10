provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "main" {
  name     = "RG-${var.prefix}"
  location = var.location
}
