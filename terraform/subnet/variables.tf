#variable "General" {}
variable "resource_group_name" {
	type	= string
}

variable "location" {
	type	= string
}

#Subnet variable {}
variable "subnet_name" {
	type	= string
}
variable "subnet_CIDR" {
	type	= list(string)
}
variable "vnet-name" { 
	type	= string
}
