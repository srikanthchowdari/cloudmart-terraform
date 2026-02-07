# Terraform Backend Configuration for PROD
# Generated: Fri Feb  6 19:25:04 IST 2026
# NOTE: In production, use a separate storage account!

resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate1770386065"
container_name       = "tfstate"
key                  = "prod/cloudmart.tfstate"
use_azuread_auth     = true
