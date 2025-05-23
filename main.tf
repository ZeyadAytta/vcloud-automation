module "vcloud_vm" {
  source = "./modules/vcloud-vm"
  
  for_each = local.vm_configs
  
  # VM Configuration
  vm_name       = each.value.name
  vm_description = each.value.description
  catalog_name  = var.catalog_name
  template_name = each.value.template_name
  
  # Resource allocation
  cpus      = each.value.cpus
  cpu_cores = each.value.cpu_cores
  memory    = each.value.memory
  
  # Storage configuration
  disk_size = lookup(each.value, "disk_size_in_mb", null)
  
  # Network configuration - convert to module format
  networks = [{
    type               = "org"
    name               = each.value.network_name
    ip_allocation_mode = each.value.ip_allocation_mode
    ip                 = lookup(each.value, "ip_address", null)
    is_primary         = true
  }]
  
  # Guest customization - convert to module format
  customization = {
    admin_password = lookup(each.value, "admin_password", null)
    auto_generate_password = lookup(each.value, "auto_generate_password", false)
  }
  
  # Power management
  power_on = lookup(each.value, "power_on", true)
  
  # Tags and metadata
  metadata = merge(local.common_tags, lookup(each.value, "metadata", {}))
  
  # Dependencies
  depends_on = [
    data.vcd_catalog_vapp_template.template,
    data.vcd_network_routed.network
  ]
}