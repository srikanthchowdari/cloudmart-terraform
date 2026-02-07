# DEMONSTRATES: App Service Plan with lifecycle rules
resource "azurerm_service_plan" "this" {
  name                = "plan-${var.app_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  
  tags = var.tags
  
  lifecycle {
    create_before_destroy = true  # Blue/green updates
  }
}

# DEMONSTRATES: Linux Web App with advanced config
resource "azurerm_linux_web_app" "this" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  
  site_config {
    always_on = var.environment == "prod" ? true : false
    
    application_stack {
      node_version = "18-lts"
    }
  }
  
  # DEMONSTRATES: App settings with merge
  app_settings = merge(
    {
      "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
      "ENVIRONMENT"                  = var.environment
    },
    var.app_settings
  )
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],  # Deployment changes
    ]
  }
}

# DEMONSTRATES: VNet integration (separate resource)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.subnet_id
}

# DEMONSTRATES: Deployment slot (staging) - conditional creation
resource "azurerm_linux_web_app_slot" "staging" {
  count = var.environment == "prod" ? 1 : 0
  
  name           = "staging"
  app_service_id = azurerm_linux_web_app.this.id
  
  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
  
  tags = var.tags
}