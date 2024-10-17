terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "3.116.0"
		}
	}
}

provider "azurerm" {
	features {}
}

resource "azurerm_resource_group" "rg01" {
	name = "rg01"
	location = "East US 2"
}

module "sub1" {
	source = "./subnet"
	resource_group_name = azurerm_resource_group.rg01.name
	location = azurerm_resource_group.rg01.location
	subnet_name = "sub1"
	subnet_CIDR = ["10.0.1.0/24"]
	vnet-name = "example-network"
}

module "cluster1" {
	source = "./cluster"
	resource_group_name = azurerm_resource_group.rg01.name
	location = azurerm_resource_group.rg01.location
}

module "vm1" {
	source = "./vm"
	resource_group_name = azurerm_resource_group.rg01.name
	location = azurerm_resource_group.rg01.location
	subnet_id = module.sub1.subnet_id
}
	
