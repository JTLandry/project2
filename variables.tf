variable "T3RGname" {
  type        = string
  description = "resource group name"
}

variable "T3location" {
  type        = string
  description = "location"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "addres space for vnet"
}

variable "vnetname" {
  type        = string
  description = "vnet name"
}

variable "subnetname1" {
  type        = string
  description = "subnet 1 name"
}

variable "tagcreator" {
  type        = string
  description = "tag creator"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      CreatedBy = "Justin_Chen"
   }
}

variable "application_port" {
   description = "Port that you want to expose to the external load balancer"
   default     = 80
}