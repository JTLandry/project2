#terraform plan
#terraform init
#terraform apply -auto-approve
#https://www.terraform.io/language/functions/cidrsubnet

resource "azurerm_resource_group" "main" {

  #  name     = "JustinP2_EastUS"
  #  location = "eastus"
  name     = var.T3RGname
  location = var.T3location
  tags = {
    CreatedBy = var.tagcreator
  }
}
# resource "azurerm_resource_group" "main2" {

#   name     = var.T3RGname2
#   location = var.T3location2

# }

resource "azurerm_mysql_server" "main" {
  name                = "t3mysqlserver"
  location            = var.T3location
  resource_group_name = azurerm_resource_group.main.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

# resource "azurerm_mysql_server" "main2" {
#   name                = "t3mysqlserver2"
#   location            = var.T3location2
#   resource_group_name = azurerm_resource_group.main2.name

#   administrator_login          = "mysqladminun"
#   administrator_login_password = "H@Sh1CoR3!"

#   sku_name   = "GP_Gen5_2"
#   storage_mb = 5120
#   version    = "5.7"

#   auto_grow_enabled                 = true
#   backup_retention_days             = 7
#   geo_redundant_backup_enabled      = true
#   infrastructure_encryption_enabled = true
#   public_network_access_enabled     = false
#   ssl_enforcement_enabled           = true
#   ssl_minimal_tls_version_enforced  = "TLS1_2"
# }

resource "azurerm_mysql_database" "main" {
  name                = "t3database"
  resource_group_name = var.T3RGname
  server_name         = azurerm_mysql_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"

  provisioner "local-exec" {
    command = "az mysql server replica create --name ${azurerm_mysql_server.main.name}-replica --location westus --resource-group ${azurerm_resource_group.main.name} --source-server ${azurerm_mysql_server.main.name}"
  }
}