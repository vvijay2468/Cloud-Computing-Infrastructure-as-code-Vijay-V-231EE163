terraform {
   required_version = ">= 0.12"
   required_providers {
      azurerm = "~>3.0.0"
   }
}

provider "azurerm" {
   subscription_id = var.subscription_id
   tenant_id = var.tenant_id
   features {}
}

resource "azurerm_resource_group" "Res_t" {
   name = "Res"
   location = var.location
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "VNet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.Res_t.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_availability_set" "set1" {
  name                = "Set1"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
}

resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports"
   resource_group_name = azurerm_resource_group.Res_t.name
   location = azurerm_resource_group.Res_t.location
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "80"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }
}



resource "azurerm_network_interface" "vm1" {
   name                = "nginx-interface-vm1"
   location            = azurerm_resource_group.Res_t.location
   resource_group_name = azurerm_resource_group.Res_t.name

   ip_configuration {
       name                          = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id                    = azurerm_subnet.subnet1.id
   }

   depends_on = [azurerm_resource_group.Res_t]
}

resource "azurerm_network_interface" "vm2" {
   name                = "nginx-interface-vm2"
   location            = azurerm_resource_group.Res_t.location
   resource_group_name = azurerm_resource_group.Res_t.name

   ip_configuration {
       name                          = "internal"
       private_ip_address_allocation = "Dynamic"
       subnet_id                    = azurerm_subnet.subnet1.id
   }

   depends_on = [azurerm_resource_group.Res_t]
}

resource "azurerm_linux_virtual_machine" "vm1" {
   name                = "vm1-webserver"
   resource_group_name = azurerm_resource_group.Res_t.name
   location            = azurerm_resource_group.Res_t.location
   size                = var.instance_size
   custom_data         = base64encode(file("scripts/init_vm1.sh"))
   network_interface_ids = [
       azurerm_network_interface.vm1.id,
   ]

   source_image_reference {
       publisher = "Canonical"
       offer     = "UbuntuServer"
       sku       = "18.04-LTS"
       version   = "latest"
   }
   lifecycle {
        prevent_destroy = false
    }

   admin_username                  = "adminuser"
   admin_password                  = "Test@123"
   disable_password_authentication = false

   os_disk {
       name                 = "vm1disk"
       caching              = "ReadWrite"
       storage_account_type = "Standard_LRS"
   }
   depends_on = [ azurerm_availability_set.set1 ]

   tags = {
       environment = var.environment
       costcenter  = "it"
   }
}

resource "azurerm_linux_virtual_machine" "vm2" {
   name                = "vm2-webserver"
   resource_group_name = azurerm_resource_group.Res_t.name
   location            = azurerm_resource_group.Res_t.location
   size                = var.instance_size
   custom_data         = base64encode(file("scripts/init_vm2.sh"))
   network_interface_ids = [
       azurerm_network_interface.vm2.id,
   ]

   source_image_reference {
       publisher = "Canonical"
       offer     = "UbuntuServer"
       sku       = "18.04-LTS"
       version   = "latest"
   }

   admin_username                  = "adminuser"
   admin_password                  = "Test@123"
   disable_password_authentication = false

   os_disk {
       name                 = "vm2disk"
       caching              = "ReadWrite"
       storage_account_type = "Standard_LRS"
   }
   depends_on = [ azurerm_availability_set.set1 ]


   tags = {
       environment = var.environment
       costcenter  = "it"
   }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.allowedports.id
  depends_on = [
    azurerm_network_security_group.allowedports
  ]
}

resource "azurerm_public_ip" "load_ip" {
  name                = "load-ip"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name
  allocation_method   = "Static"
  sku="Standard"
}

resource "azurerm_lb" "app_balancer" {
  name                = "app-balancer"
  location            = azurerm_resource_group.Res_t.location
  resource_group_name = azurerm_resource_group.Res_t.name
  sku="Standard"
  sku_tier = "Regional"
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }

  depends_on=[
    azurerm_public_ip.load_ip
  ]
}

// Here we are defining the backend pool
resource "azurerm_lb_backend_address_pool" "PoolA" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "PoolA"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm1_address" {
  name                    = "appvm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.vnet1.id
  ip_address              = azurerm_network_interface.vm1.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm2_address" {
  name                    = "appvm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.vnet1.id
  ip_address              = azurerm_network_interface.vm2.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}


// Here we are defining the Health Probe
resource "azurerm_lb_probe" "app_lb_probe" {
  name                = "app-lb-http-probe"
  loadbalancer_id     = azurerm_lb.app_balancer.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}
// Here we are defining the Load Balancing Rule
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.PoolA.id ]
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

// This is used for creating the NAT Rules

resource "azurerm_lb_nat_rule" "NATRuleA" {
  resource_group_name            = azurerm_resource_group.Res_t.name
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "frontend-ip"
  depends_on                     = [azurerm_lb.app_balancer]
}
