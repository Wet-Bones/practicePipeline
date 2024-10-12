resource "azurerm_virtual_machine" "ansible_vm" {
	name					= "ansible-vm"
	resource_group_name		= var.resource_group_name
	location				= var.location
	network_interface_ids   = [azure_network_interface.nic.id]
	vm_size					= "Standard B1ms"

	os_profile {
		computer_name  = "ansible-vm"
		admin_username = "ansibleadmin"
		admin_password = "Password1234!"
	}

	os_profile_linux_config {
		disable_password_authentication = false
	}

	storage_image_reference {
		publisher = "Canonical"
		offer	  = "UbuntuServer"
		sku		  = "18.04-LTS"
		version   = "latest"
	}

	storage_os_disk {
		name			= "ansible-os-disk"
		caching			= "ReadWrite"
		create_option	= "FromImage"
		managed_disk_type = "Standard_LRS"
	}
}

resource "null_resource" "ansible_provision" {
	depends_on = [azure_virtual_machine.ansible_vm]

	provisioner "remote-exec" {
		connection {
			type		= "ssh"
			user		= "ansibleadmin"
			password	= "Password1234!"
			host		= azure_virtual_machine.ansible_vm.public_ip_address
		}

		inline = [
			"sudo apt-get update",
			"sudo apt-get install -y ansible",
			"ansible-playbook ../../ansible/playbook.yml
		]
	}
}
