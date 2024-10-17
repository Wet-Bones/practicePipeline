variable "resource_group_name" {
	type	= string
}

variable "location" {
	type	= string
}

variable "subnet_id" {
	description = "the ID of the subnet where the VM will be deployed"
}
