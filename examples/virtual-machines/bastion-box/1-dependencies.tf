resource "azurerm_resource_group" "sandbox" {
  name     = "${var.prefix}-sandbox-rsg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "sandbox" {
  name                = "sandbox-network"
  location            = "${azurerm_resource_group.sandbox.location}"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "dmz" {
  name                      = "${azurerm_resource_group.sandbox.name}-dmz"
  virtual_network_name      = "${azurerm_virtual_network.sandbox.name}"
  resource_group_name       = "${azurerm_resource_group.sandbox.name}"
  address_prefix            = "10.0.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.dmz.id}"
}

resource "azurerm_subnet" "secure" {
  name                      = "${azurerm_resource_group.sandbox.name}-secure"
  virtual_network_name      = "${azurerm_virtual_network.sandbox.name}"
  resource_group_name       = "${azurerm_resource_group.sandbox.name}"
  address_prefix            = "10.0.10.0/24"
  network_security_group_id = "${azurerm_network_security_group.secure.id}"
}

resource "azurerm_network_security_group" "dmz" {
  name                = "sandbox-dmz-nsg"
  location            = "${azurerm_resource_group.sandbox.location}"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"

  security_rule {
    name                       = "allow-ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "secure" {
  name                = "sandbox-secure-nsg"
  location            = "${azurerm_resource_group.sandbox.location}"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"

  security_rule {
    name                       = "allow-from-dmz-ssh"
    description                = "Allow From DMZ SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${azurerm_subnet.dmz.address_prefix}"
    destination_address_prefix = "*"
  }
}
