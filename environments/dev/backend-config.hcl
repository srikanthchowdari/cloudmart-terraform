# Terraform Backend Configuration for DEV
# Generated: Fri Feb  6 19:25:04 IST 2026

resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate1770386065"
container_name       = "tfstate"
key                  = "dev/cloudmart.tfstate"
use_azuread_auth     = true
