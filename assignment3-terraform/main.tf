provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-assignment3"
  location = "northeurope"
}

locals {
  instance_count = 2
}

resource "azurerm_virtual_network" "vnet-northeurope" {
  name                = "vnet-assignment3-northeurope"
  address_space       = ["10.0.0.0/16"]
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "snet-northeurope" {
  name                 = "snet-assignment3-northeurope"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet-northeurope.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "pip-northeurope" {
  name                = "pip-assignment3-northeurope"
  resource_group_name = azurerm_resource_group.this.name
  location            = "northeurope"
  allocation_method   = "Dynamic"
  domain_name_label   = "pip-assignment3-northeurope"
}

resource "azurerm_network_interface" "nic-northeurope" {
  count               = local.instance_count
  name                = "nic-assignment3-northeurope-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = "northeurope"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.snet-northeurope.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset-northeurope" {
  name                         = "avset-assignment3-northeurope"
  location                     = "northeurope"
  resource_group_name          = azurerm_resource_group.this.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_security_group" "nsg-northeurope" {
  name                = "nsg-assignment3-northeurope"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.this.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-association-northeurope" {
  subnet_id                 = azurerm_subnet.snet-northeurope.id
  network_security_group_id = azurerm_network_security_group.nsg-northeurope.id
}

resource "azurerm_lb" "lb-northeurope" {
  name                = "lb-assignment3-northeurope"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.this.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip-northeurope.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-bap-northeurope" {
  loadbalancer_id     = azurerm_lb.lb-northeurope.id
  name                = "lb-bap-assignment3-northeurope"
}

resource "azurerm_lb_nat_rule" "lb-nat-northeurope" {
  resource_group_name            = azurerm_resource_group.this.name
  loadbalancer_id                = azurerm_lb.lb-northeurope.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.lb-northeurope.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-association-northeurope" {
  count                   = local.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bap-northeurope.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.nic-northeurope.*.id, count.index)
}

resource "azurerm_linux_virtual_machine" "vm-northeurope" {
  count                           = local.instance_count
  name                            = "vm-assignment3-northeurope-${count.index}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = "northeurope"
  size                            = "Standard_F2"
  admin_username                  = "serveradmin"
  admin_password                  = "Aa123456789!"
  availability_set_id             = azurerm_availability_set.avset-northeurope.id
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-northeurope[count.index].id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}


resource "azurerm_virtual_network" "vnet-eastus" {
  name                = "vnet-assignment3-eastus"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "snet-eastus" {
  name                 = "snet-assignment3-eastus"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet-eastus.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "pip-eastus" {
  name                = "pip-assignment3-eastus"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus"
  allocation_method   = "Dynamic"
  domain_name_label   = "pip-assignment3-eastus"
}

resource "azurerm_network_interface" "nic-eastus" {
  count               = local.instance_count
  name                = "nic-assignment3-eastus-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.snet-eastus.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset-eastus" {
  name                         = "avset-assignment3-eastus"
  location                     = "eastus"
  resource_group_name          = azurerm_resource_group.this.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_security_group" "nsg-eastus" {
  name                = "nsg-assignment3-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-association-eastus" {
  subnet_id                 = azurerm_subnet.snet-eastus.id
  network_security_group_id = azurerm_network_security_group.nsg-eastus.id
}

resource "azurerm_lb" "lb-eastus" {
  name                = "lb-assignment3-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip-eastus.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-bap-eastus" {
  loadbalancer_id     = azurerm_lb.lb-eastus.id
  name                = "lb-bap-assignment3-eastus"
}

resource "azurerm_lb_nat_rule" "lb-nat-eastus" {
  resource_group_name            = azurerm_resource_group.this.name
  loadbalancer_id                = azurerm_lb.lb-eastus.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.lb-eastus.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-association-eastus" {
  count                   = local.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bap-eastus.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.nic-eastus.*.id, count.index)
}

resource "azurerm_linux_virtual_machine" "vm-eastus" {
  count                           = local.instance_count
  name                            = "vm-assignment3-eastus-${count.index}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = "eastus"
  size                            = "Standard_F2"
  admin_username                  = "serveradmin"
  admin_password                  = "Aa123456789!"
  availability_set_id             = azurerm_availability_set.avset-eastus.id
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-eastus[count.index].id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "tm-assignment3"
  resource_group_name    = azurerm_resource_group.this.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "tm-assignment3"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 22
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "lb-ep-northeurope" {
  name               = "lb-ep-assignment-northeurope"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_public_ip.pip-northeurope.id
  weight = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "lb-ep-eastus" {
  name               = "lb-ep-assignment-eastus"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_public_ip.pip-eastus.id
  weight = 1
}
