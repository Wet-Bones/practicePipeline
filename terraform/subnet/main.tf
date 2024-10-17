resource "azurerm_virtual_network" "vnet1" {
	name			= var.vnet-name
	address_space		= ["10.0.0.0/16"]
	location		= var.location
	resource_group_name	= var.resource_group_name
}

resource "azurerm_subnet" "snet1" {
	#count = length(var.subnet_name)
	name			= var.subnet_name
	resource_group_name	= var.resource_group_name
	virtual_network_name	= var.vnet-name
	address_prefixes	= var.subnet_CIDR

	depends_on = [azurerm_virtual_network.vnet1]
}

output "subnet_id" {
	value = azurerm_subnet.snet1.id
}
