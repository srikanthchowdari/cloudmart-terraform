package main

import rego.v1

# Storage account naming - too short
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    name := resource.change.after.name
    count(name) < 3
    
    msg := sprintf(
        "❌ Storage Account name '%s' is too short. Minimum 3 characters.",
        [name]
    )
}

# Storage account naming - too long
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    name := resource.change.after.name
    count(name) > 24
    
    msg := sprintf(
        "❌ Storage Account name '%s' is too long. Maximum 24 characters.",
        [name]
    )
}

# Resource group naming convention
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_resource_group"
    
    name := resource.change.after.name
    not startswith(name, "rg-")
    
    msg := sprintf(
        "❌ Resource Group '%s' does not follow naming convention: rg-{project}-{environment}",
        [name]
    )
}