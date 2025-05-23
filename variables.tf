# main.tf - Root module
terraform {
  required_version = ">= 1.0"
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "~> 3.10"
    }
  }
}

# Provider configuration
provider "vcd" {
  user                 = var.vcd_user
  password             = var.vcd_password
  auth_type            = "integrated"
  org                  = var.vcd_org
  vdc                  = var.vcd_vdc
  url                  = var.vcd_url
  max_retry_timeout    = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}

# Local values for common configurations
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
  
  vm_configs = {
    for vm in var.virtual_machines : vm.name => vm
  }
}

# Data sources
data "vcd_org_vdc" "main" {
  name = var.vcd_vdc
}

data "vcd_catalog" "main" {
  name = var.catalog_name
}

data "vcd_catalog_vapp_template" "template" {
  for_each    = local.vm_configs
  catalog_id  = data.vcd_catalog.main.id
  name        = each.value.template_name
}

data "vcd_network_routed" "network" {
  for_each = toset([for vm in var.virtual_machines : vm.network_name])
  name     = each.key
  vdc      = var.vcd_vdc
}

# Create VMs using the module
module "vcloud_vm" {
  source = "./modules/vcloud-vm"
  
  for_each = local.vm_configs
  
  # VM Configuration
  vm_name                = each.value.name
  vm_description         = each.value.description
  catalog_name           = var.catalog_name
  template_name          = each.value.template_name
  
  # Resource allocation
  cpus                   = each.value.cpus
  cpu_cores              = each.value.cpu_cores
  memory                 = each.value.memory
  
  # Storage configuration
  storage_profile        = each.value.storage_profile
  disk_size_in_mb       = each.value.disk_size_in_mb
  additional_disks      = lookup(each.value, "additional_disks", [])
  
  # Network configuration
  network_name          = each.value.network_name
  ip_allocation_mode    = each.value.ip_allocation_mode
  ip_address           = lookup(each.value, "ip_address", null)
  
  # OS customization
  computer_name        = each.value.computer_name
  admin_password       = each.value.admin_password
  auto_generate_password = lookup(each.value, "auto_generate_password", false)
  password_policy_enabled = lookup(each.value, "password_policy_enabled", true)
  
  # Power management
  power_on             = lookup(each.value, "power_on", true)
  
  # Tags and metadata
  metadata             = merge(local.common_tags, lookup(each.value, "metadata", {}))
  
  # Dependencies
  depends_on = [
    data.vcd_catalog_vapp_template.template,
    data.vcd_network_routed.network
  ]
}

# variables.tf - Root module variables
variable "vcd_user" {
  description = "vCloud Director username"
  type        = string
}

variable "vcd_password" {
  description = "vCloud Director password"
  type        = string
  sensitive   = true
}

variable "vcd_org" {
  description = "vCloud Director organization"
  type        = string
}

variable "vcd_vdc" {
  description = "vCloud Director VDC name"
  type        = string
}

variable "vcd_url" {
  description = "vCloud Director URL"
  type        = string
}

variable "vcd_max_retry_timeout" {
  description = "Maximum retry timeout for vCloud Director operations"
  type        = number
  default     = 60
}

variable "vcd_allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = false
}

variable "catalog_name" {
  description = "vCloud Director catalog name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "vcloud-infrastructure"
}

variable "virtual_machines" {
  description = "List of virtual machines to create"
  type = list(object({
    name                    = string
    description            = optional(string, "VM managed by Terraform")
    template_name          = string
    cpus                   = number
    cpu_cores              = optional(number, 1)
    memory                 = number
    storage_profile        = optional(string, "")
    disk_size_in_mb       = optional(number, 10240)
    network_name          = string
    ip_allocation_mode    = optional(string, "DHCP")
    ip_address           = optional(string)
    computer_name        = string
    admin_password       = optional(string)
    auto_generate_password = optional(bool, false)
    password_policy_enabled = optional(bool, true)
    power_on             = optional(bool, true)
    metadata             = optional(map(string), {})
    additional_disks     = optional(list(object({
      name            = string
      size_in_mb     = number
      bus_type       = optional(string, "SCSI")
      bus_sub_type   = optional(string, "lsilogicsas")
      storage_profile = optional(string, "")
    })), [])
  }))
  default = []
}