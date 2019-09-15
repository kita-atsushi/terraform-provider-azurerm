locals {
  admin_username       = "testadmin"
}

# Server:DMZ
resource "azurerm_network_interface" "jumpserver" {
  name                      = "jumpserver-nic"
  location                  = "${azurerm_resource_group.sandbox.location}"
  resource_group_name       = "${azurerm_resource_group.sandbox.name}"
  network_security_group_id = "${azurerm_network_security_group.dmz.id}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${azurerm_subnet.dmz.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpserver.id}"
  }
}

resource "azurerm_public_ip" "jumpserver" {
  name                = "sandbox-pip"
  location            = "${azurerm_resource_group.sandbox.location}"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-jumpserver"
}

resource "azurerm_virtual_machine" "jumpserver" {
  name                  = "jumpserver"
  location              = "${azurerm_resource_group.sandbox.location}"
  resource_group_name   = "${azurerm_resource_group.sandbox.name}"
  network_interface_ids = ["${azurerm_network_interface.jumpserver.id}"]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jump-server-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "jump-server"
    admin_username = "${local.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${local.admin_username}/.ssh/authorized_keys"
      key_data = "${local.public_ssh_key}"
    }
  }
}

# Server:Secure
resource "azurerm_network_interface" "secureserver" {
  name                      = "secureserver-nic"
  location                  = "${azurerm_resource_group.sandbox.location}"
  resource_group_name       = "${azurerm_resource_group.sandbox.name}"
  network_security_group_id = "${azurerm_network_security_group.secure.id}"

  ip_configuration {
    name                          = "secure-internal"
    subnet_id                     = "${azurerm_subnet.secure.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "secure-server" {
  name                  = "secure-server"
  location              = "${azurerm_resource_group.sandbox.location}"
  resource_group_name   = "${azurerm_resource_group.sandbox.name}"
  network_interface_ids = ["${azurerm_network_interface.secureserver.id}"]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "secure-server-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "secure-server"
    admin_username = "${local.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${local.admin_username}/.ssh/authorized_keys"
      key_data = "${local.public_ssh_key}"
    }
  }
}
