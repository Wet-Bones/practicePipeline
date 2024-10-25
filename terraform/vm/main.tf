resource "azurerm_public_ip" "vm_public_ip" {
	name				= "public-ip"
	location			= var.location
	resource_group_name	= var.resource_group_name
	allocation_method	= "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                    = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id		= azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_virtual_machine" "ansible_vm" {
	name					= "ansible-vm"
	resource_group_name		= var.resource_group_name
	location				= var.location
	network_interface_ids   = [azurerm_network_interface.nic.id]
	vm_size					= "Standard_B1ls"

	os_profile {
		computer_name  = "ansible-vm"
		admin_username = "ansibleadmin"
		admin_password = "Password1234!"
	}

	os_profile_linux_config {
		disable_password_authentication = true

		
		ssh_keys {
			path = "/home/ansibleadmin/.ssh/authorized_keys"
			key_data = file("/home/nathaniel/.ssh/id_ed25519.pub")
		}
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
	depends_on = [azurerm_virtual_machine.ansible_vm, azurerm_public_ip.vm_public_ip]

	provisioner "file" {
		source		= "/home/nathaniel/practice_pipeline/ansible/playbook.yml"
		destination = "/home/ansibleadmin/playbook.yml"

		connection {
			type = "ssh"
			user = "ansibleadmin"
			private_key = file("/home/nathaniel/.ssh/id_ed25519")
			host = azurerm_public_ip.vm_public_ip.ip_address
		}
	}

	provisioner "remote-exec" {
		connection {
			type		= "ssh"
			user		= "ansibleadmin"
			private_key	= file("/home/nathaniel/.ssh/id_ed25519")
			host		= azurerm_public_ip.vm_public_ip.ip_address
		}

		inline = [
			"ls -l /home/ansibleadmin",
			"cat /home/ansibleadmin/playbook.yml",
			"sudo apt-get update",
			"sudo apt-get install -y ansible",
			"ansible-playbook /home/ansibleadmin/playbook.yml",
			"mkdir -p /home/ansibleadmin/python_app/",
			"ls -la /home/ansibleadmin"
		]
	}

	provisioner "file" {
			source		= "/home/nathaniel/practice_pipeline/python_app/"
			destination = "/home/ansibleadmin/python_app/"
	
			connection {
				type = "ssh"
				user = "ansibleadmin"
				private_key = file("/home/nathaniel/.ssh/id_ed25519")
				host = azurerm_public_ip.vm_public_ip.ip_address
			}
		}
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
