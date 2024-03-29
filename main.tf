terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.82.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
   skip_provider_registration = "true"
   features {}
}

resource "azurerm_resource_group" "AzureFirewallCapture" {
  name = var.resource_group
  location = var.location
}

data "azurerm_subscription" "sub-test" {
}
