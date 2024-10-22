resource "azurerm_resource_group" "ajrg" {
  name     = "ajrg"
  location = "centralindia"

}
resource "azurerm_virtual_network" "ajvnet" {
  name                = "ajvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "centralindia"
  resource_group_name = "ajrg"
  depends_on          = [azurerm_resource_group.ajrg]
}

resource "azurerm_subnet" "ajsn" {
  name                 = "ajsn"
  resource_group_name  = "ajrg"
  virtual_network_name = "ajvnet"
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.ajvnet]
}

resource "azurerm_public_ip" "ajpip" {
  name                = "ajpip"
  resource_group_name = "ajrg"
  location            = "centralindia"
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "ajnic" {
  name                = "ajnic"
  location            = "centralindia"
  resource_group_name = "ajrg"

  ip_configuration {
    name                          = "ajip"
    subnet_id                     = data.azurerm_subnet.ajdata_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ajpip.id
  }
}

resource "azurerm_linux_virtual_machine" "ajvm" {
  name                = "ajvm"
  resource_group_name = azurerm_resource_group.ajrg.name
  location            = azurerm_resource_group.ajrg.location
  size                = "Standard_F2"
  admin_username      = data.azurerm_key_vault_secret.username.value
  admin_password      = data.azurerm_key_vault_secret.password.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ajnic.id
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

provider "azurerm" {
  features {
    
  }
  
}

variable "db_password" {
  type = string
  sensitive = true
  
}

provider "azurerm" {
  features {
    
  }
  
}

data "azurerm_key_vault" "Ajkv" {
  name = "ajkeyvault"
  resource_group_name = "ajrg"
}

data "azurerm_key_vault_secret" "db_pass"{
  name = "db_password"
  key_vault_id = data.azurerm_key_vault.ajkey.id
}

resource "azurerm_sql_server" "sever_name" {
  name = "aj_sql_server"
  resource_group_name = "ajrg"
  location = "East Us"
  version = "12.0"
  administrator_login = "admin user"
  administrator_login_password = data.azurerm_key_vault_secret.db_pass.value
}


# Get Detail from Existing Reource Group 

data "azurerm_resource_group" "RG" {
  name ="ajrg"

}
  # Use the Resource Group detail when creating a new Storage Account

resource "azurerm_storage_account" "sa" {
  name = "ajstg"
  resource_group_name = data.azurerm_resource_group.RG
  location = data.azurerm_resource_group.location
  account_tier = "standard"
  account_replication_type = "LRS"
  
}