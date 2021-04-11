variable "rg" {
  type = string
}
variable "location" {
  type    = string
  default = "uksouth"
}
variable "nsg_rule" {
  description = "nsg rules"
  type = list(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}