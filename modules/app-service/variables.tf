variable "app_name" {
  description = "App Service name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
}

variable "sku_name" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
  
  validation {
    condition     = can(regex("^(B[1-3]|S[1-3]|P[1-3]v[2-3]|F1|D1)$", var.sku_name))
    error_message = "SKU must be a valid App Service Plan SKU."
  }
}

variable "app_settings" {
  description = "Application settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
}