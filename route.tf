resource "azurerm_route_table" "route-table" {
  name                = "rt-${var.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
}

resource "azurerm_route" "route" {
  name                = "route-${var.prefix}"
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  route_table_name    = azurerm_route_table.route-table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.FirewallCapture.ip_configuration.0.private_ip_address
}