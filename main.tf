terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  subscription_id = "d6b978a6-550c-496b-91f3-4e859bb8df90"
}

# Create a resource group
resource "azurerm_resource_group" "Res_t" {
  name     = "Res"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "VNet1_t" {
  name                = "VNet1"
  resource_group_name = azurerm_resource_group.Res_t.name
  location            = azurerm_resource_group.Res_t.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_availability_set" "Set1_t" {
  name                = "Set1"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name

  tags = {
    name = "Set1"
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnet_t" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Res_t.name
  virtual_network_name = azurerm_virtual_network.VNet1_t.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "example-nsg"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic_t.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_network_interface" "nic_t" {
  name                = "example-nic"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_t.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.examplePublicIP.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.Res_t.name
  location            = azurerm_resource_group.Res_t.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_t.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

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

resource "azurerm_public_ip" "examplePublicIP" {
  name                = "examplePublicIP"
  resource_group_name = azurerm_resource_group.Res_t.name
  location            = azurerm_resource_group.Res_t.location
  allocation_method   = "Static"
}



output "vm_public_ip" {
  value = azurerm_public_ip.examplePublicIP.ip_address
  description = "Public IP address of the VM"
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.example.name
  description = "Name of the VM"
}

output "resource_group" {
  value = azurerm_resource_group.Res_t.name
  description = "Resource group name"
}
