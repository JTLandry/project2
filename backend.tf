terraform {
  backend "azurerm" {
    resource_group_name  = "jchenRG"
    storage_account_name = "jcstoragess"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}