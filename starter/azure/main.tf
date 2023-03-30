data "azurerm_resource_group" "udacity" {
  name     = "Regroup_2g0ZOql9u2VfzAGKM3TLMH"
}

resource "azurerm_container_group" "udacity" {
  name                = "udacity-continst"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-alves-azure"
  os_type             = "Linux"

  container {
    name   = "azure-container-app"
    image  = "docker.io/tscotto5/azure_app:1.0"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "AWS_S3_BUCKET"       = "uda-alves-aws-s3",
      "AWS_DYNAMO_INSTANCE" = "uda-alves-dynamodb"
    }
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
  tags = {
    environment = "udacity"
  }
}

####### Your Additions Will Start Here ######
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
#

resource "azurerm_storage_account" "udacity" {
  name                     = "udaalvessto"
  resource_group_name      = data.azurerm_resource_group.udacity.name
  location                 = data.azurerm_resource_group.udacity.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_server

resource "azurerm_mssql_server" "udacity" {
  name                         = "uda-alves-az-mssql"
  resource_group_name          = data.azurerm_resource_group.udacity.name
  location                     = data.azurerm_resource_group.udacity.location
  version                      = "12.0"
  administrator_login          = "justadminuda"
  administrator_login_password = "minE#mikA#1945@"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database

resource "azurerm_mssql_database" "udacity" {
  name           = "uda-mssql-db"
  server_id      = azurerm_mssql_server.udacity.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 150
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    name        = "uda-mssql-db"
    environment = "udacity"
  }
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan

resource "azurerm_service_plan" "udacity" {
  name                = "uda-sp"
  resource_group_name = data.azurerm_resource_group.udacity.name
  location            = data.azurerm_resource_group.udacity.location
  os_type             = "Windows"
  sku_name            = "P1v2"
}


resource "azurerm_windows_web_app" "udacity" {
  name                = "udaalvesazdotnet"
  resource_group_name = data.azurerm_resource_group.udacity.name
  location            = azurerm_service_plan.udacity.location
  service_plan_id     = azurerm_service_plan.udacity.id

  site_config {}
}

####

