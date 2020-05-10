output "resource_group_id" {
  value = "${data.azurerm_resource_group.main.id}"
}
output "resource_group_location" {
  value = "${data.azurerm_resource_group.main.location}"
}
output "virtnetwork_id" {
  value = "${azurerm_virtual_network.main.id}"
}