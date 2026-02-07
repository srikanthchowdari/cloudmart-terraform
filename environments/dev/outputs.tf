output "resource_group_name" {
  description = "Resource group name"
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of all subnet IDs"
  value       = module.networking.subnet_ids
}

output "nsg_id" {
  description = "Network Security Group ID"
  value       = module.networking.nsg_id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.demo.name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.demo.id
}

output "primary_blob_endpoint" {
  description = "Primary blob storage endpoint"
  value       = azurerm_storage_account.demo.primary_blob_endpoint
}

output "storage_containers" {
  description = "List of container names"
  value       = [for c in azurerm_storage_container.containers : c.name]
}

output "container_urls" {
  description = "Map of container URLs"
  value       = local.container_urls
}

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    resource_group = module.networking.resource_group_name
    location       = module.networking.location
    vnet           = module.networking.vnet_name
    subnets        = length(keys(module.networking.subnet_ids))
    storage        = azurerm_storage_account.demo.name
    containers     = length(azurerm_storage_container.containers)
  }
}