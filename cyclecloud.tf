# carte reseaux ip publique
resource "azurerm_network_interface" "cyclecloud" {
  name                = "vm-${var.prefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.admin.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id = azurerm_public_ip.cycle.id
  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "cyclecloud" {
  name                = "vm-${var.prefix}-cyclecloud"
  location            = var.location
  resource_group_name = azurerm_resource_group.AzureFirewallCapture.name
  vm_size             = var.cyclecloud_vm_size

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.cyclecloud.id,
  ]

  plan {
    name      = var.vm_image.plan_sku
    publisher = var.vm_image.publisher
    product   = var.vm_image.product_offer
  }

  storage_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.product_offer
    sku       = var.vm_image.plan_sku
    version   = var.vm_image.version
  }

  storage_os_disk {
    name              = "vm-${var.prefix}-cyclecloud-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.vm_managed_disk_type
  }

  os_profile {
    computer_name  = "vm-${var.prefix}-cyclecloud"
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
    custom_data    = base64encode( <<CUSTOM_DATA
#cloud-config
write_files:
- content: |
    [{
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.initial_user",
        "Value": "${var.vm_admin_username}"
    },
    {
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.complete",
        "Value": true
    },
    {
        "AdType": "AuthenticatedUser",
        "Name": "${var.vm_admin_username}",
        "RawPassword": "${var.vm_admin_password}",
        "Superuser": true
    }] 
  owner: root:root
  path: ./account_data.json
  permissions: '0644'
- content: |
    {
      "Name": "Azure",
      "Environment": "public",
      "AzureRMSubscriptionId": "${data.azurerm_subscription.sub-test.subscription_id}",
      "AzureRMUseManagedIdentity": true,
      "Location": "${var.location}",
      "RMStorageAccount": "${azurerm_storage_account.cyclecloud.name}",
      "RMStorageContainer": "cyclecloud"
    }
  owner: root:root
  path: ./azure_data.json
  permissions: '0644'
runcmd:
# - sed -i --follow-symlinks "s/webServerMaxHeapSize=.*/webServerMaxHeapSize=4096M/g" /opt/cycle_server/config/cycle_server.properties
# - sed -i --follow-symlinks "s/webServerPort=.*/webServerPort=80/g" /opt/cycle_server/config/cycle_server.properties
# - sed -i --follow-symlinks "s/webServerSslPort=.*/webServerSslPort=443/g" /opt/cycle_server/config/cycle_server.properties
# - sed -i --follow-symlinks "s/webServerEnableHttps=.*/webServerEnableHttps=true/g" /opt/cycle_server/config/cycle_server.properties
- mv ./account_data.json /opt/cycle_server/config/data/
- sleep 60
- /opt/cycle_server/cycle_server execute "update Application.Setting set Value = false where name == \"authorization.check_datastore_permissions\""
- /usr/local/bin/cyclecloud initialize --batch --url=https://localhost --verify-ssl=false --username="${var.vm_admin_username}" --password="${var.vm_admin_password}"
- /usr/local/bin/cyclecloud account create -f ./azure_data.json
  CUSTOM_DATA
  )
}

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags

}

resource "azurerm_managed_disk" "cyclecloud" {
  name                 = "vm-${var.prefix}-cyclecloud-DataDisk1"
  location             = var.location
  resource_group_name  = azurerm_resource_group.AzureFirewallCapture.name
  storage_account_type = var.vm_managed_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_data_disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "cyclecloud" {
  managed_disk_id    = azurerm_managed_disk.cyclecloud.id
  virtual_machine_id = azurerm_virtual_machine.cyclecloud.id
  lun                = "1"
  caching            = "ReadOnly"
}

resource "random_string" "random" {
  length = 8
  special = false
  lower = true
  upper = false
}


resource "azurerm_storage_account" "cyclecloud" {
  name                     = "sa${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.AzureFirewallCapture.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_role_assignment" "cyclecloud" {
  scope                = data.azurerm_subscription.sub-test.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_virtual_machine.cyclecloud.identity[0].principal_id

}