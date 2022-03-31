# AzureUseFirewallCaptureTraffic

This github is a mix of different documentations to track all external requests from a service, a VM or something else attached to a virtual network.

See below the sources
* [How to implement Azure Firewall](https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)
* [Monitor logs using Azure Firewall Workbook](https://docs.microsoft.com/en-us/azure/firewall/firewall-workbook)
* [Deploy a workbook on Azure](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20Firewall/Workbook%20-%20Azure%20Firewall%20Monitor%20Workbook)

For this example, thanks to Terraform we will deploy the following:
* Azure Virtual Network with 3 subnets 
    * admin
    * AzureBastionSubnet 
    * AzureFirewallSubnet
* **Azure Route**, will route all the trafic to the Firewall
* **Azure Bastion**, will be used to connect on the VM if needed
* **Azure Firewall** with **Azure policy**, will trace/blocks/allow all the requests
* **Azure CycleCloud** latest, for testing a service
* **Azure Log Analytics**, will saved all the usefull for information
* **Azure workbook**, will display all the access into saved into log Analytics

To deploy the solution you need
* Terraform
* Access to Azure
* Rights to deploy into the subscription
* git


```
git clone https://github.com/AlexandreJean/AzureUseFirewallCaptureTraffic.git
cd AzureUseFirewallCaptureTraffic

```

The solution deployed by Terraform won't be ready as is. We will need to perform some steps on the Azure Portal directly.

