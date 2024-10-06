output "resource_group_name" {
  description = "The name of the resource group created."
  value       = azurerm_resource_group.Res_t.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network created."
  value       = azurerm_virtual_network.vnet1.id
}

output "subnet_id" {
  description = "The ID of the subnet created."
  value       = azurerm_subnet.subnet1.id
}

output "availability_set_name" {
  description = "The name of the availability set created."
  value       = azurerm_availability_set.set1.name
}

output "vm1_private_ip" {
  description = "The private IP address of VM1."
  value       = azurerm_network_interface.vm1.private_ip_address
}

output "vm2_private_ip" {
  description = "The private IP address of VM2."
  value       = azurerm_network_interface.vm2.private_ip_address
}


output "load_balancer_public_ip" {
  description = "The public IP address of the load balancer."
  value       = azurerm_public_ip.load_ip.ip_address
}

output "backend_pool_id" {
  description = "The ID of the backend pool for the load balancer."
  value       = azurerm_lb_backend_address_pool.PoolA.id
}

output "health_probe_name" {
  description = "The name of the health probe used for the load balancer."
  value       = azurerm_lb_probe.app_lb_probe.name
}

output "load_balancing_rule_name" {
  description = "The name of the load balancing rule."
  value       = azurerm_lb_rule.RuleA.name
}
