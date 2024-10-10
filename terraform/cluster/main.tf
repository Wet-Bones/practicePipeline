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
		node_count  = 2
		vm_size		= "Standard_D2pls_v5"
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
