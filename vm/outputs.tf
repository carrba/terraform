output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "domain_name_label" {
  value = azurerm_public_ip.main.domain_name_label
}