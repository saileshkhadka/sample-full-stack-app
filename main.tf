# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTaskDeployVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet for Frontend
resource "azurerm_subnet" "frontend_subnet" {
  name                 = "frontend_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Subnet for Backend
resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create Azure Web App for Frontend
resource "azurerm_app_service" "frontend_app" {
  name                = "myFrontendApp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.frontend_app_service_plan.id
}

# Create App Service Plan for Frontend
resource "azurerm_app_service_plan" "frontend_app_service_plan" {
  name                = "myFrontendAppServicePlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create Azure Web App for Backend
resource "azurerm_app_service" "backend_app" {
  name                = "myBackendApp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.backend_app_service_plan.id
}

# Create App Service Plan for Backend
resource "azurerm_app_service_plan" "backend_app_service_plan" {
  name                = "myBackendAppServicePlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create Azure SQL Database
resource "azurerm_sql_server" "sql_server" {
  name                         = "myTaskDeploySqlServer"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "Sailesh"
  administrator_login_password = "Sailesh@2024?"
}

resource "azurerm_sql_database" "sql_database" {
  name                = "myTaskDeploySqlDatabase"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = "Standard"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
}

# Create Network Security Group for Frontend
resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Network Security Group for Backend
resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define security rules for NSG
resource "azurerm_network_security_rule" "frontend_nsg_rule" {
  name                        = "frontend_nsg_rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.frontend_nsg.name
}

resource "azurerm_network_security_rule" "backend_nsg_rule" {
  name                        = "backend_nsg_rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3001"  
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.backend_nsg.name
}

# Create Azure Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = "myKeyVault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  enabled_for_disk_encryption        = true
  enabled_for_deployment             = true
  enabled_for_template_deployment   = true
}

# Azure Key Vault Access Policy for Backend
resource "azurerm_key_vault_access_policy" "backend_key_vault_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "task-deploy-object-id"
  secret_permissions = [
    "get",
    "list",
  ]
}

# Azure Monitor and Log Analytics for Backend App Service
resource "azurerm_monitor_diagnostic_setting" "backend_app_monitoring" {
  name                       = "backend_app_monitoring"
  target_resource_id        = azurerm_app_service.backend_app.id
  log_analytics_workspace_id = "my-log-workspace-id"
  metrics {
    category = "AllMetrics"
  }
  logs {
    category = "AppServiceHTTPLogs"
  }
}

# HTTPS Configuration for Web App
resource "azurerm_app_service_custom_hostname_binding" "frontend_app_https" {
  hostname        = "frontend_app.azurewebsites.net"
  app_service_id  = azurerm_app_service.frontend_app.id
  resource_group_name = azurerm_resource_group.rg.name
}
