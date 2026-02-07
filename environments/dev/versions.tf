# environments/dev/versions.tf

terraform {
  required_version = ">= 1.6.0" # Pin minimum version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0" # Allow patch updates (3.85.x), not minor (3.86)
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.12.0"
    }
  }

  # Remote backend configuration
  backend "azurerm" {
    # Values provided via backend-config file or -backend-config flags
    # Never hardcode these in version control!
  }
}