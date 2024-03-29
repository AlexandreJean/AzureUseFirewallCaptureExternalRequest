# Introduction : How to capture traffic from a virtual machine on Azure

This GitHub is a mix of different documentation to track all requests from a service, a VM or something else attached to a virtual network. If you need to build a whitelist to authorize protocol, FQDN or follow your request on a fresh VNET your are at the right place. 
Into this gihtub I am not covering
* How to monitor a current VNET into your solution (you will need to adjust the Terraform)

# Initialisation
For this example, thanks to Terraform you will deploy the following:
* **Azure Virtual Network** with 3 subnets 
    * admin
    * AzureBastionSubnet 
    * AzureFirewallSubnet
* **Azure Route**, will route all the trafic to the Firewall
* **Azure Bastion**, will be used to connect on the VM if needed
* **Azure Firewall** with **Azure policy**, will trace/block/allow all the requests
* **Azure CycleCloud** latest, for testing a service
* **Azure Log Analytics**, will save all the useful for information
* **Azure workbook**, will display all the access into saved into log Analytics

To deploy the solution you need
* Terraform
* Access to Azure form the place you will deploy (cloudshell, VM etc)
* Rights to deploy into the subscription
* git

```
git clone https://github.com/AlexandreJean/AzureUseFirewallCaptureTraffic.git
cd AzureUseFirewallCaptureTraffic
```
Edit terraform.tfvars or others files, according to your need. Basically you have a file per funtion, if you don't need Bastion you just have to delete bastion.tf etc.

By default, with this files you will have 
* 1x Aure Firewall Policy application rule : to allow all protocol on 80 and 443 (file firewall.tf)
* 1x DNAT rule : to redirect HTTS requests to the internal CycleCloud portal (file firewall.tf)
* 1x route : to redirect all traffic to firewall (file route.tf)

# Deploy solution
Once you have customize all the files, you can run Terraform commands, you need to have the azure access configured prior to run the command with the associated rights:
```
terraform init
terraform plan
terraform apply
```

The solution deployed by Terraform won't be ready as it is. You will need to perform some steps on the Azure Portal directly.

1) Link the Azure Firewall policy to the VNET
1) Link firewall to log analytics
1) Add dashboard 

## Link the Azure Firewall policy to the VNET
Unfortunately, at this moment into this tutorial, we need to run some manual action, please follow the step by step below, and click on the orange square:
![Firewall Picture #1](/images/Slide1.PNG)

![Firewall Picture #2](/images/Slide2.PNG)

![Firewall Picture #3](/images/Slide3.PNG)

![Firewall Picture #4](/images/Slide4.PNG)

![Firewall Picture #5](/images/Slide5.PNG)

## Link firewall to log analytics
On the firewall resource go to Diagnostic settings

![Firewall Picture #6](/images/Slide6.PNG)

![Firewall Picture #7](/images/Slide7.PNG)


## Add dashboard 
* go to this github website: [Deploy a workbook on Azure](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20Firewall/Workbook%20-%20Azure%20Firewall%20Monitor%20Workbook)
* click on **Deploy to Azure** select the resource group where you want to deploy the dashboard
*  click on **Review + create**.

# visualize

If you connect on the virtual machine and you run an ssh command to an IP on internet it will be logged as follow into the dashboard:
![Firewall Picture #8](/images/Slide8.PNG)

And then scrolldown to see the requests, into the example I tried to ssh a IP:
![Firewall Picture #9](/images/Slide9.PNG)

# Sources
See below the sources :
* [How to implement Azure Firewall](https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)
* [Monitor logs using Azure Firewall Workbook](https://docs.microsoft.com/en-us/azure/firewall/firewall-workbook)
* [Deploy a workbook on Azure](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20Firewall/Workbook%20-%20Azure%20Firewall%20Monitor%20Workbook)