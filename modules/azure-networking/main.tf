# DEMONSTRATES: Resource creation, lifecycle rules, tagging strategy
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, { ManagedBy = "Terraform" })
  
  lifecycle {
    prevent_destroy = false  # Set to true in production
    ignore_changes  = [tags["CreatedDate"]]  # Ignore Azure-added tags
  }
}

# DEMONSTRATES: Basic resource with computed values
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.vnet_address_space
  
  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Component   = "Networking"
    }
  )
}

# DEMONSTRATES: for_each with complex objects, dynamic blocks, optional attributes
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  
  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
  
  # DEMONSTRATES: Dynamic blocks with conditional logic
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    
    content {
      name = delegation.value.name
      
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# DEMONSTRATES: NSG with dynamic security rules using for_each
resource "azurerm_network_security_group" "this" {
  name                = "${var.vnet_name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  
  tags = var.tags
}

# DEMONSTRATES: Separate resource for rules (better for management)
resource "azurerm_network_security_rule" "rules" {
  for_each = var.nsg_rules
  
  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
}

# DEMONSTRATES: Association resources, depends_on for explicit ordering
# resource "azurerm_subnet_network_security_group_association" "aks" {
#   subnet_id                 = azurerm_subnet.subnets["aks"].id
#   network_security_group_id = azurerm_network_security_group.this.id
  
#   depends_on = [
#     azurerm_network_security_rule.rules  # Ensure all rules exist first
#   ]
# }

# DEMONSTRATES: locals for complex calculations
locals {
  # Extract all subnet IDs for easy reference
  subnet_ids = { for k, v in azurerm_subnet.subnets : k => v.id }
  
  # Common tags that get applied everywhere
  common_tags = {
    ManagedBy   = "Terraform"
    Module      = "azure-networking"
    Environment = var.environment
  }
}