# main.tf

provider "azurerm" {
  features {}
}

# Define a resource group
resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = "East US"
}

# Define a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define a subnet
resource "azurerm_subnet" "example" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define a public IP address
resource "azurerm_public_ip" "example" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Define a network interface
resource "azurerm_network_interface" "example" {
  name                = "myNIC"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNICConfiguration"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Define a virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"

  admin_username      = "adminuser"
  admin_password      = "Password1234!"

  network_interface_ids = [azurerm_network_interface.example.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Output the public IP of the virtual machine
output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}
