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