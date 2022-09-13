# resource "azurerm_resource_group" "scaleset" {
#   name     = "example-resources"
#   location = "West Europe"
# }

# resource "azurerm_virtual_network" "example" {
#   name                = "acctvn"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_subnet" "example" {
#   name                 = "acctsub"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

resource "azurerm_public_ip" "LBandScaleset" {
  name                = "T3PubIP1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = "t3resourcegroup"

  tags = {
    CreatedBy = var.tagcreator
  }
}

resource "azurerm_lb" "LBandScaleset" {
  name                = "T3LoadBalancer1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    CreatedBy = var.tagcreator
  }
  frontend_ip_configuration {
    name                 = "T3PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.LBandScaleset.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  # resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.LBandScaleset.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.main.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.LBandScaleset.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "T3PublicIPAddress"
}

resource "azurerm_lb_probe" "LBandScaleset" {
  # resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.LBandScaleset.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/health"
  port                = 8080
}

resource "azurerm_virtual_machine_scale_set" "LBandScaleset" {
  name                = "T3scaleset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.LBandScaleset.id

  sku {
    name     = "Standard_B2s"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "azureuser"
    admin_password = "Testpass111!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    # ssh_keys {
    #   path     = "/home/myadmin/.ssh/authorized_keys"
    #   key_data = file("~/.ssh/demo_key.pub")
    # }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.network.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }

  tags = {
    CreatedBy = var.tagcreator
  }
}