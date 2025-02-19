resource "random_id" "acr_suffix" {
	byte_length = 4
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
	name				= "testCluster"
	location			= var.location
	resource_group_name = var.resource_group_name
	dns_prefix			= "testdns"

	default_node_pool {
		name		= "default"
		node_count  = 1
		vm_size		= "Standard_D2s_v3"
	}

	identity {
		type = "SystemAssigned"
	}

	network_profile {
		network_plugin = "azure"
	}
}

resource "azurerm_container_registry" "acr" {
	name				= "testContainerRegistry${random_id.acr_suffix.hex}"
	resource_group_name	= var.resource_group_name
	location			= var.location
	sku					= "Basic"
}

data "azurerm_client_config" "current" {}

output "acr_name" {
	value = azurerm_container_registry.acr.name
	description = "name of Azure Container Registry"
}

output "azure_client_id" {
	value = data.azurerm_client_config.current.client_id
	description = "Azure Client ID"
}

output "azure_tenant_id" {
	value = data.azurerm_client_config.current.tenant_id
	description = "Azure Tenant ID"
}

output "azure_subscription_id" {
	value = data.azurerm_client_config.current.subscription_id
	description = "Azure Subscription ID"
}

