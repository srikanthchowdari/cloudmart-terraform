

# Module 1: Networking (demonstrates: for_each, dynamic blocks, validation)
module "networking" {
  source = "../../modules/azure-networking"
  
  resource_group_name = "rg-${var.project_name}-${var.environment}"
  location            = var.location
  vnet_name           = "vnet-${var.project_name}"
  vnet_address_space  = ["10.0.0.0/16"]
  environment         = var.environment
  
  subnets = {
    web = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      delegation        = null
    }
    data = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
      delegation        = null
    }
    mgmt = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = []
      delegation        = null
    }
  }
  
  nsg_rules = {
    allow_https = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    allow_http = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    allow_storage = {
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
    }
  }
  
  tags = local.common_tags
}

# Resource: Storage Account (demonstrates: conditionals, lifecycle rules)
resource "azurerm_storage_account" "demo" {
  name                     = replace("st${var.project_name}${var.environment}", "-", "")
  resource_group_name      = module.networking.resource_group_name
  location                 = module.networking.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  enable_https_traffic_only       = true
  
  blob_properties {
    versioning_enabled = var.environment == "prod" ? true : false
    
    dynamic "delete_retention_policy" {
      for_each = var.environment == "prod" ? [1] : []
      content {
        days = 30
      }
    }
  }
  
  # network_rules {
  #   default_action             = "Deny"
  #   virtual_network_subnet_ids = [
  #     module.networking.subnet_ids["web"],
  #     module.networking.subnet_ids["data"]
  #   ]
  #   bypass = ["AzureServices"]
  # }
  
  tags = local.common_tags
  
  lifecycle {
    prevent_destroy = false
  }
}

# Resource: Storage Containers (demonstrates: for_each with set)
resource "azurerm_storage_container" "containers" {
  for_each = toset(["uploads", "images", "documents", "backups", "logs"])
  
  name                  = each.value
  storage_account_name  = azurerm_storage_account.demo.name
  container_access_type = "private"
}

# Resource: Storage Lifecycle Policy (demonstrates: dynamic blocks, complex objects)
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.demo.id
  
  rule {
    name    = "delete-old-uploads"
    enabled = true
    
    filters {
      prefix_match = ["uploads/"]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
  
  rule {
    name    = "delete-old-logs"
    enabled = true
    
    filters {
      prefix_match = ["logs/"]
      blob_types   = ["blockBlob"]
    }
    
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}

# Locals (demonstrates: computed values, tag merging)
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    # ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    CreatedBy   = "Srikanth"
  }
  
  container_urls = {
    for k, v in azurerm_storage_container.containers :
    k => "https://${azurerm_storage_account.demo.name}.blob.core.windows.net/${v.name}"
  }
}