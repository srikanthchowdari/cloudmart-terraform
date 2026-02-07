package main

import rego.v1

# Deny storage accounts that allow public blob access
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    allow_public := resource.change.after.allow_nested_items_to_be_public
    allow_public == true
    
    msg := sprintf(
        "❌ Storage Account '%s' allows public blob access. This violates security policy.",
        [resource.address]
    )
}

# Deny storage accounts not using TLS 1.2
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    tls_version := resource.change.after.min_tls_version
    tls_version != "TLS1_2"
    
    msg := sprintf(
        "❌ Storage Account '%s' uses TLS version '%s'. Minimum required is TLS1_2.",
        [resource.address, tls_version]
    )
}

# Deny storage accounts not enforcing HTTPS
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    https_only := resource.change.after.enable_https_traffic_only
    https_only != true
    
    msg := sprintf(
        "❌ Storage Account '%s' does not enforce HTTPS-only traffic.",
        [resource.address]
    )
}

# Warn if production resources don't have versioning
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    
    env := resource.change.after.tags.Environment
    env == "prod"
    
    blob_props := resource.change.after.blob_properties[_]
    versioning := blob_props.versioning_enabled
    versioning != true
    
    msg := sprintf(
        "⚠️  Storage Account '%s' in production does not have blob versioning enabled.",
        [resource.address]
    )
}