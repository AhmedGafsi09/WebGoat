provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "webgoat_rg" {
  name     = "webgoat-rg"
  location = "East US"
}

# Network Security Group
resource "azurerm_network_security_group" "webgoat_nsg" {
  name                = "webgoat-nsg"
  location            = azurerm_resource_group.webgoat_rg.location
  resource_group_name = azurerm_resource_group.webgoat_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WebGoat"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "8080"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "webgoat_vnet" {
  name                = "webgoat-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.webgoat_rg.location
  resource_group_name = azurerm_resource_group.webgoat_rg.name
}

# Subnet
resource "azurerm_subnet" "webgoat_subnet" {
  name                 = "webgoat-subnet"
  resource_group_name  = azurerm_resource_group.webgoat_rg.name
  virtual_network_name = azurerm_virtual_network.webgoat_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "webgoat_pip" {
  name                = "webgoat-pip"
  location            = azurerm_resource_group.webgoat_rg.location
  resource_group_name = azurerm_resource_group.webgoat_rg.name
  allocation_method   = "Static"
}

# VM
resource "azurerm_linux_virtual_machine" "webgoat_vm" {
  name                = "webgoat-vm"
  location            = azurerm_resource_group.webgoat_rg.location
  resource_group_name = azurerm_resource_group.webgoat_rg.name
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.webgoat_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

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
}

# Network Interface
resource "azurerm_network_interface" "webgoat_nic" {
  name                = "webgoat-nic"
  location            = azurerm_resource_group.webgoat_rg.location
  resource_group_name = azurerm_resource_group.webgoat_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.webgoat_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webgoat_pip.id
  }
}

output "public_ip" {
  value = azurerm_public_ip.webgoat_pip.ip_address
}