#network for cyclecloud, master, compute, Bastion
resource "azurerm_virtual_network" "vnet" {
  name                = "vn-${var.prefix}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  tags                = var.tags
}

resource "azurerm_subnet" "admin" {
  name                 = "admin"
  resource_group_name  = azurerm_resource_group.AzureFirewallCapture.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.snet_address_space_admin
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.AzureFirewallCapture.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.snet_address_space_firewall
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.AzureFirewallCapture.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.snet_address_space_bastion
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall-${var.prefix}"
  location            = var.location 
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.prefix}"
  location            = var.location 
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource "azurerm_public_ip" "cycle" {
#   name                = "pip-cycle-${var.prefix}"
#   location            = var.location 
#   resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

resource "azurerm_subnet_route_table_association" "ta-admin" {
  subnet_id      = azurerm_subnet.admin.id
  route_table_id = azurerm_route_table.route-table.id
}