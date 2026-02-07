package main

import rego.v1

# Deny expensive storage replication types in dev
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    replication := resource.change.after.account_replication_type
    env := resource.change.after.tags.Environment
    
    env in ["dev", "staging"]
    replication in ["GRS", "RAGRS", "GZRS", "RAGZRS"]
    
    msg := sprintf(
        "❌ Storage Account '%s' uses expensive replication '%s' in '%s' environment. Use LRS for dev/staging.",
        [resource.address, replication, env]
    )
}

# Deny Premium storage in dev
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    tier := resource.change.after.account_tier
    env := resource.change.after.tags.Environment
    
    env in ["dev", "staging"]
    tier == "Premium"
    
    msg := sprintf(
        "❌ Storage Account '%s' uses Premium tier in '%s' environment. Use Standard for cost optimization.",
        [resource.address, env]
    )
}