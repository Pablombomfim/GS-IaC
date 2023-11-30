resource "azurerm_resource_group" "rg" {
  name     = "RG-Iac-Test"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "staticsite-vm-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet-1" {
  name                 = "staticsite-vm-subnet-1"
  resource_group_name  = "RG-Iac-Test"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet-2" {
  name                 = "staticsite-vm-subnet-2"
  resource_group_name  = "RG-Iac-Test"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "public-ip" {
  name                = "unique-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "timmaiavseminem2"
}
resource "azurerm_network_security_group" "sgdaazurelb" {
  name                = "staticsite-vm-nsg"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  security_rule {
    name                       = "HTTP-Inbound"
    priority                   = 1021
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Outbound"
    priority                   = 1023
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "sgdasvm" {
  name                = "staticsite-vm-nsg"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  security_rule {
    name                       = "HTTP-Inbound"
    priority                   = 1021
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH-Inbound"
    priority                   = 1022
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Outbound"
    priority                   = 1023
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic-azurelb" {
  name                = "staticsite-vm-nic-azurelb"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  ip_configuration {
    name                          = "staticsite-vm-nic-azurelb-ip"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_network_interface" "nic-azurevm-1" {
  name                = "staticsite-vm-nic-azurevm-1"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  ip_configuration {
    name                          = "staticsite-vm-nic-azurevm-ip"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic-azurevm-2" {
  name                = "staticsite-vm-nic-azurevm-2"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  ip_configuration {
    name                          = "staticsite-vm-nic-azurevm-ip"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic-azurevm-3" {
  name                = "staticsite-vm-nic-azurevm-3"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  ip_configuration {
    name                          = "staticsite-vm-nic-azurevm-ip"
    subnet_id                     = azurerm_subnet.subnet-2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic-azurevm-4" {
  name                = "staticsite-vm-nic-azurevm-4"
  location            = "eastus"
  resource_group_name = "RG-Iac-Test"
  ip_configuration {
    name                          = "staticsite-vm-nic-azurevm-ip"
    subnet_id                     = azurerm_subnet.subnet-2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "maquina1" {
  name                  = "staticsite-vm-1"
  location              = "eastus"
  resource_group_name   = "RG-Iac-Test"
  network_interface_ids = [azurerm_network_interface.nic-azurevm-1.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "staticsite-vm-osdisk-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "staticsite-vm-1"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
    custom_data    = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apache2
      echo '<html><body><h1>AWS bem melhor, falei e sai correndo</h1></body></html>' | sudo tee /var/www/html/index.html
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "maquina2" {
  name                  = "staticsite-vm-2"
  location              = "eastus"
  resource_group_name   = "RG-Iac-Test"
  network_interface_ids = [azurerm_network_interface.nic-azurevm-2.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "staticsite-vm-osdisk-2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "staticsite-vm-2"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
    custom_data    = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apache2
      echo '<html><body><h1>AWS bem melhor, falei e sai correndo</h1></body></html>' | sudo tee /var/www/html/index.html
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "maquina3" {
  name                  = "staticsite-vm-3"
  location              = "eastus"
  resource_group_name   = "RG-Iac-Test"
  network_interface_ids = [azurerm_network_interface.nic-azurevm-3.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "staticsite-vm-osdisk-3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "staticsite-vm-3"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
    custom_data    = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apache2
      echo '<html><body><h1>Hello, World!</h1></body></html>' | sudo tee /var/www/html/index.html
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "maquina4" {
  name                  = "staticsite-vm-4"
  location              = "eastus"
  resource_group_name   = "RG-Iac-Test"
  network_interface_ids = [azurerm_network_interface.nic-azurevm-4.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "staticsite-vm-osdisk-4"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "staticsite-vm-4"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
    custom_data    = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y apache2
      echo '<html><body><h1>Hello, World!</h1></body></html>' | sudo tee /var/www/html/index.html
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

