terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.69"
    }
  }
  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "Infra-Resource"
    storage_account_name = "configterraformsa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

locals {
  tags = {
    env = "dev"
  }
}

resource "azurerm_resource_group" "waRG" {
  name     = "${var.resourceGroupName}-rg-${var.env}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_mssql_server" "waSQLServer" {
  name                         = "${var.resourceGroupName}-sql-${var.env}"
  resource_group_name          = azurerm_resource_group.waRG.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sqlAdminUser
  administrator_login_password = var.sqlAdminPass
  minimum_tls_version          = "1.2"
  tags                         = local.tags
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_firewall_rule" "waSQLFW" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.waSQLServer.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "waSQLDb" {
  name         = var.sqlDbName
  server_id    = azurerm_mssql_server.waSQLServer.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2

  #read_scale     = true
  sku_name = var.sqlDbSKU
  #zone_redundant = true
  tags = local.tags
}

output "sql_identity" {
  value = azurerm_mssql_server.waSQLServer.identity[0].principal_id

  # The EC2 instance must have an encrypted root volume.
}

resource "azurerm_service_plan" "waasp" {
  name                = "${var.aspName}-asp-${var.env}"
  resource_group_name = azurerm_resource_group.waRG.name
  location            = azurerm_resource_group.waRG.location
  os_type             = "Linux"
  sku_name            = "S1"
  tags                = local.tags
}

resource "azurerm_linux_web_app" "appservice" {
  name                = "${var.webappName}-webapp-${var.env}"
  location            = azurerm_resource_group.waRG.location
  resource_group_name = azurerm_resource_group.waRG.name
  service_plan_id     = azurerm_service_plan.waasp.id

  site_config {
    always_on           = true
    http2_enabled       = true
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "18-lts"
    }
    cors {
      allowed_origins = ["*", "https://portal.azure.com"] // Specify allowed origins
    }
  }

  # app_settings = {
  #   "SOME_KEY" = "some-value"
  # }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:skillhub-sql-dev.database.windows.net,1433;Database=${azurerm_mssql_database.waSQLDb.name};Uid=${azurerm_mssql_server.waSQLServer.administrator_login};Pwd=${azurerm_mssql_server.waSQLServer.administrator_login_password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  }
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags
}

output "sql_connection_string" {
  value = "Server=tcp:skillhub-sql-dev.database.windows.net,1433;Database=${azurerm_mssql_database.waSQLDb.name};Uid=${azurerm_mssql_server.waSQLServer.administrator_login};Pwd=${azurerm_mssql_server.waSQLServer.administrator_login_password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  sensitive = true
}

