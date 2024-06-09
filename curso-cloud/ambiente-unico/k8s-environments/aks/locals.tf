# az login
# az account set --subscription "014edaf3-fae6-4300-9a4a-1c32361b7d64"

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "this" {
  name     = "personal"
  location = var.region
}