

resource "azurerm_traffic_manager_profile" "example" {
  name                   = "trafficmanagerprofile"
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "trafficmanagerprofile"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = var.tags
}

resource "azurerm_traffic_manager_azure_endpoint" "example" {
  name               = "endpoint1"
  profile_id         = azurerm_traffic_manager_profile.example.id
  weight             = 100
  target_resource_id = azurerm_public_ip.vmss.id
}

# resource "azurerm_traffic_manager_azure_endpoint" "example2" {
#   name               = "endpoint2"
#   profile_id         = azurerm_traffic_manager_profile.example.id
#   weight             = 200
#   target_resource_id = azurerm_public_ip.vmss.id
#   #needs the pub ip of the second load balancer
# }