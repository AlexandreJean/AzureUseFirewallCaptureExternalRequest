resource "azurerm_firewall" "FirewallCapture" {
  name                = "fw-${var.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  sku_tier            = "Premium"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  } 
}

resource "azurerm_firewall_policy" "AzureFirewallCapture" {
  name                = "fwpolicy-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
}

resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  name                      = "fwpolicy-rcg"
  firewall_policy_id        = azurerm_firewall_policy.AzureFirewallCapture.id
  priority                  = 300
  application_rule_collection {
      name                  = "app_rule_collection1_rule1"
      action                = "Allow"
      priority              = 300
      rule {
            name                  = "network_rule_collection1_rule1"

            protocols{
                port              = "443"
                type              = "Https"
            }
            protocols{
                port              = "80"
                type              = "Http"
            }
            source_addresses      = ["*"]
            destination_fqdns    = ["*"]
     }
  }
  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 101
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.firewall.ip_address
      destination_ports   = ["443"]
      translated_address  = azurerm_network_interface.cyclecloud.private_ip_address
      translated_port     = "443"
    }
  }
}

# resource "azurerm_firewall_nat_rule_collection" "dnat" {
#   name                = "dnat-testcollection"
#   azure_firewall_name = azurerm_firewall.FirewallCapture.name
#   resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
#   priority            = 100
#   action              = "Dnat"

#   rule {
#     name = "httpstocycle"

#     source_addresses = [
#       "*",
#     ]

#     destination_ports = [
#       "443",
#     ]

#     destination_addresses = [
#       azurerm_public_ip.firewall.ip_address
#     ]

#     translated_port = 443
#     translated_address = azurerm_network_interface.cyclecloud.private_ip_address

#     protocols = [
#       "TCP",
#       "UDP",
#     ]
#   }
# }