locals {
  # Read YAML configuration
  yaml_config = yamldecode(file("${path.module}/vcloud-tasks/createvm.yaml"))
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
  
  # Convert YAML VMs to terraform format
  vm_configs = {
    for vm in local.yaml_config.vms : vm.name => {
      name               = vm.name
      description        = vm.description
      template_name      = vm.template_name
      cpus              = vm.cpus
      cpu_cores         = vm.cpu_cores
      memory            = vm.memory
      power_on          = vm.power_on
      # Extract network info from YAML
      network_name      = vm.networks[0].name
      ip_allocation_mode = vm.networks[0].ip_allocation_mode
      # Extract customization
      admin_password    = vm.customization.admin_password
      initscript       = vm.customization.initscript
      # Extract metadata
      metadata         = vm.metadata
    }
  }
}

# Data sources
data "vcd_org_vdc" "main" {
  name = var.vcd_vdc
}

data "vcd_catalog" "main" {
  name = "Public Catalog"
}

data "vcd_catalog_vapp_template" "template" {
  for_each    = local.vm_configs
  catalog_id  = data.vcd_catalog.main.id
  name        = each.value.template_name
}

data "vcd_network_routed" "network" {
  for_each = toset([for vm in local.vm_configs : vm.network_name])
  name     = each.key
  vdc      = var.vcd_vdc
}