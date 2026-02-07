output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.this.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default hostname"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "app_service_url" {
  description = "App Service URL"
  value       = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses"
  value       = azurerm_linux_web_app.this.outbound_ip_addresses
}