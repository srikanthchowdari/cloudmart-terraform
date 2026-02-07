# DEMONSTRATES: Comprehensive outputs for module composition

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.this.id
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = local.subnet_ids
}


output "nsg_id" {
  description = "Network Security Group ID"
  value       = azurerm_network_security_group.this.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.this.location
}