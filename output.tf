output "RG_name" {
  value = data.azurerm_resource_group.main.name
}

output "RG_location" {
  value = data.azurerm_resource_group.main.location
}

output "VM_domain_name" {
  value = module.vm.domain_name_label
}

output "VM_public_IP" {
  value = module.vm.public_ip_address
}
