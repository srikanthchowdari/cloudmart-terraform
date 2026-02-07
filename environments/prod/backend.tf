# environments/prod/backend.tf

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-prod-rg"  # Separate RG!
    storage_account_name = "tfstateprod67890"         # Separate storage!
    container_name       = "tfstate"
    key                  = "prod/cloudmart.tfstate"
    
    use_azuread_auth     = true
  }
}