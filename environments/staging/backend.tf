# environments/staging/backend.tf

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "staging/cloudmart.tfstate"  # Different path
    
    use_azuread_auth     = true
  }
}