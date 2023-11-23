provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "resourceGroup"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
    count                = 1
    location             = azurerm_resource_group.rg.location
    resource_group_name  = azurerm_resource_group.rg.name
    name                 = "vm-${count.index}"
    vm_size              = "Standard_DS1_v2"

    storage_os_disk {
        name              = "osdisk-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    network_interface_ids = [azurerm_network_interface.nic.*.id[count.index]]
}

resource "azurerm_network_interface" "nic" {
    count               = 2
    name                = "nic${count.index}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "ipconfig"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }

    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "vm${count.index}"
        admin_username = "adminuser"
        admin_password = "AdminPassword123!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
