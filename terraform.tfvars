#terraform.tfvars
resource_group = "rg-AzureFirewall"
prefix         = "Firewall"
location       = "westeurope"
tags = {
BusinessUnit = "FirewallCaptureTest"
Category =  "Cloud"
CostCenter = ""
DataClassification = "Confidential"
Environment = "Dev"
Owner = "alexandre.jean@microsoft.com"
WorkloadName =   "FirewallCaptureTest"
}

#Vnet
vnet_address_space                = ["10.6.0.0/16"]
snet_address_space_admin          = ["10.6.0.0/28"]
snet_address_space_firewall       = ["10.6.1.0/26"]
snet_address_space_bastion        = ["10.6.2.0/26"]

vm_admin_username             = "hpcadmin"
#vm_admin_password             = ""
cyclecloud_vm_size            = "Standard_DS2_v2"
jumpbox_vm_size               = "Standard_D2s_v3"
vm_managed_disk_type          = "Standard_LRS"
vm_data_disk_size_gb          = 128
vm_image = {
  publisher     = "azurecyclecloud"
  product_offer = "azure-cyclecloud"
  plan_sku      = "cyclecloud8"
  version       = "latest"
  }