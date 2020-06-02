provider "azurerm" {
  features{}
}

# NIC Interface with DNS Servers specified
resource "azurerm_network_interface" "DNS" {
  count                     = var.dns[0] != "" ? 1 : 0
  name                      = "${var.computer_name}-nic"
  location                  = var.RG_location
  resource_group_name       = var.RG_name
  # network_security_group_id = var.Security_Group_ID
  dns_servers               = var.dns

  ip_configuration {
    name      = "IPconfiguration"
    subnet_id = var.subnet_ID

    # private_ip_address_allocation = "${var.private_ip_allocation}"
    private_ip_address_allocation = var.private_ip == "" ? "dynamic" : "static"
    private_ip_address            = var.private_ip
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# NIC Interface WITHOUT DNS Servers specified
resource "azurerm_network_interface" "noDNS" {
  count                     = var.dns[0] == "" ? 1 : 0
  name                      = "${var.computer_name}-nic"
  location                  = var.RG_location
  resource_group_name       = var.RG_name
  # network_security_group_id = var.Security_Group_ID

  ip_configuration {
    name      = "IPconfiguration"
    subnet_id = var.subnet_ID

    # private_ip_address_allocation = "${var.private_ip_allocation}"
    private_ip_address_allocation = var.private_ip == "" ? "dynamic" : "static"
    private_ip_address            = var.private_ip
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_public_ip" "main" {
  name                         = "${var.computer_name}-public-ip"
  location                     = var.RG_location
  resource_group_name          = var.RG_name
  # public_ip_address_allocation = "dynamic"
  allocation_method              = "Dynamic"
}

# Windows 
resource "azurerm_virtual_machine" "windows" {
  count               = var.publisher == "MicrosoftWindowsServer" ? 1 : 0
  name                = var.computer_name
  location            = var.RG_location
  resource_group_name = var.RG_name

  # network_interface_ids = ["${azurerm_network_interface.main.id}"]
  network_interface_ids = [element(
    concat(
      azurerm_network_interface.DNS.*.id,
      azurerm_network_interface.noDNS.*.id,
    ),
    0,
  )]
  vm_size = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.computer_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_windows_config {
    provision_vm_agent = "true"
  }
}

# Linux
resource "azurerm_virtual_machine" "linux" {
  count               = var.publisher != "MicrosoftWindowsServer" ? 1 : 0
  name                = var.computer_name
  location            = var.RG_location
  resource_group_name = var.RG_name

  # network_interface_ids = ["${azurerm_network_interface.main.id}"]
  network_interface_ids = [element(
    concat(
      azurerm_network_interface.DNS.*.id,
      azurerm_network_interface.noDNS.*.id,
    ),
    0,
  )]
  vm_size = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.computer_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "datadisk" {
  count                = var.data_disk_size != "" ? 1 : 0
  name                 = "${var.computer_name}-datadisk"
  location             = var.RG_location
  resource_group_name  = var.RG_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
}

# Windows attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "windowsdatadisk" {
  count              = var.data_disk_size != "" && var.publisher == "MicrosoftWindowsServer" ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.datadisk[0].id
  virtual_machine_id = azurerm_virtual_machine.windows[0].id
  lun                = "10"
  caching            = "None"
}

# Linux attach data disk
resource "azurerm_virtual_machine_data_disk_attachment" "linuxdatadisk" {
  count              = var.data_disk_size != "" && var.publisher != "MicrosoftWindowsServer" ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.datadisk[0].id
  virtual_machine_id = azurerm_virtual_machine.linux[0].id
  lun                = "10"
  caching            = "None"
}

# Windows execute Ansible PowerShell script to configure WinRM for Ansible
# Previously - Windows Install Puppet Agent Enterprise Extension. Just point
# fileUris to powershell script for Puppet to revert
resource "azurerm_virtual_machine_extension" "windows_server_ext" {
  # count              = var.publisher == "MicrosoftWindowsServer" ? 1 : 0
  count                = var.puppet_client == "windows" ? 1 : 0
  name                 = var.computer_name
  virtual_machine_id   = azurerm_virtual_machine.windows[0].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
      {
        "fileUris": [
            "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
        ],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -file ConfigureRemotingForAnsible.ps1"
      }
    
SETTINGS

}

# Linux Install Puppet Agent Enterprise Extension
resource "azurerm_virtual_machine_extension" "linux_server_ext" {
  # count              = var.publisher == "OpenLogic" ? 1 : 0
  count                = var.puppet_client == "linux" ? 1 : 0
  name                 = var.computer_name
  virtual_machine_id   = azurerm_virtual_machine.linux[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings             = <<SETTINGS
      {
        "fileUris": [
            "https://raw.githubusercontent.com/carrba/terraform_v1/azure/puppetagent.sh"
        ],
        "commandToExecute": "./puppetagent.sh"
      }
    
SETTINGS

}
