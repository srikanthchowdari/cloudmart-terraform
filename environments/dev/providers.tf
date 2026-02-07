# environments/dev/providers.tf

provider "azurerm" {

  skip_provider_registration = true  # ← Add this line
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true # Safety net
    }

    key_vault {
      purge_soft_delete_on_destroy    = false # Retain deleted secrets
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true  # Clean up disks
      skip_shutdown_and_force_delete = false # Normal deletion
    }
  }

}

provider "azuread" {
  # Uses same credentials as azurerm
}

provider "azapi" {
  # For preview features
}