package main

import rego.v1

# Required tags for all resources
required_tags := {"Environment", "Owner", "CostCenter", "Project", "ManagedBy"}

# Deny rule for missing tags on resource groups
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_resource_group"
    
    existing_tags := object.keys(resource.change.after.tags)
    missing := required_tags - existing_tags
    count(missing) > 0
    
    msg := sprintf(
        "❌ Resource Group '%s' is missing required tags: %v",
        [resource.address, missing]
    )
}

# Deny rule for missing tags on storage accounts
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    existing_tags := object.keys(resource.change.after.tags)
    missing := required_tags - existing_tags
    count(missing) > 0
    
    msg := sprintf(
        "❌ Storage Account '%s' is missing required tags: %v",
        [resource.address, missing]
    )
}

# Allow rule - informational
allow contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_resource_group"
    
    existing_tags := object.keys(resource.change.after.tags)
    missing := required_tags - existing_tags
    count(missing) == 0
    
    msg := sprintf(
        "✅ Resource Group '%s' has all required tags",
        [resource.address]
    )
}