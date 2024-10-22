data "azurerm_subnet" "ajdata_sn" {
  name                 = "ajsn"
  virtual_network_name = "ajvnet"
  resource_group_name  = "ajrg"
}
data "azurerm_key_vault" "ajkey" {
  name                = "ajkv1"
  resource_group_name = "ajrg"
}

data "azurerm_key_vault_secret" "username" {
  name         = "adminuser"
  key_vault_id = data.azurerm_key_vault.ajkey.id
}

data "azurerm_key_vault_secret" "password" {
  name         = "adminpassword"
  key_vault_id = data.azurerm_key_vault.ajkey.id
}