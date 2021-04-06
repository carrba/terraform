variable "rg" {
  type        = string
  description = "Resource group name"
}

variable "computer_name" {
  type        = string
  description = "vm name"
}

variable "admin_username" {
  type        = string
  description = "vm admin username"
  default     = "carrb"
}

variable "admin_password" {
  type        = string
  description = "vm admin user password"
  sensitive   = true
}

variable "publisher" {
  type        = string
  description = "OS image publisher"
}

variable "offer" {
  type        = string
  description = "os image offer"
}

variable "sku" {
  type        = string
  description = "os image sku"
}

variable "data_disk_size" {
  type    = string
  default = ""
}

variable "vm_size" {
  type        = string
  description = "vm size"
  default     = "Standard_B1s"
}

variable "private_ip" {
  type    = string
  default = ""
}

variable "dns" {
}

variable "puppet_client" {
  type    = string
  default = ""
}