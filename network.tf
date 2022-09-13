resource "azurerm_virtual_network" "network" {
  name                = var.vnetname
  location            = var.T3location
  resource_group_name = var.T3RGname
  address_space       = var.vnet_address_space
  tags = {
    CreatedBy = var.tagcreator
  }
}

resource "azurerm_subnet" "network" {

  name                 = var.subnetname1
  resource_group_name  = var.T3RGname
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.1.0/24"]
}