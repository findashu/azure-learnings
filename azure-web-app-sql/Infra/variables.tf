variable "env" {
  type        = string
  description = "Environment resources deployed"
  validation {
    condition     = var.env != "" && lower(var.env) == var.env
    error_message = "Environment can't be empty and in small case"
  }
}

variable "location" {
  type        = string
  default     = "East US2"
  description = "Region resources needs to be deployed"
}

variable "resourceGroupName" {
  type        = string
  description = "Name of the resource group"
}

variable "sqlDbName" {
  type        = string
  description = "Name of the Database"
}

variable "sqlDbSKU" {
  type        = string
  default     = "S0"
  description = "Tier of the database"
}

variable "sqlAdminUser" {
  type        = string
  sensitive   = true
  description = "SQL DB Admin User Name"
}

variable "sqlAdminPass" {
  type        = string
  sensitive   = true
  description = "SQL DB Admin Password"
}

variable "aspName" {
  type        = string
  sensitive   = true
  description = "App Service Plan Name"
}

variable "webappName" {
  type        = string
  sensitive   = true
  description = "App Service Name"
}
