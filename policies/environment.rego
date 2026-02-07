package main

import rego.v1

# Production lifecycle warning
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type in ["azurerm_resource_group", "azurerm_storage_account"]
    
    env := resource.change.after.tags.Environment
    env == "prod"
    
    msg := sprintf(
        "⚠️  Consider adding prevent_destroy lifecycle rule to production resource '%s'",
        [resource.address]
    )
}

# Dev environment should not have geo-redundant storage
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    env := resource.change.after.tags.Environment
    env == "dev"
    
    replication := resource.change.after.account_replication_type
    replication in ["GRS", "RAGRS", "GZRS", "RAGZRS"]
    
    msg := sprintf(
        "❌ Dev environment storage '%s' should use LRS, not '%s'",
        [resource.address, replication]
    )
}