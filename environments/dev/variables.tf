variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "interview-demo"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}
