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