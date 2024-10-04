output "vnet_subnets" {
 value = azurerm_subnet.subnet1.id
}

output "vnet_id" {
 value = azurerm_virtual_network.vnet1.id
}

output "vm1_public_ip" {
   value = azurerm_public_ip.webserver_public_ip_vm1.ip_address
}

output "vm2_public_ip" {
   value = azurerm_public_ip.webserver_public_ip_vm2.ip_address
}
