module "vcloud_vm" {
  source = "./modules/vcloud-vm"
  
  for_each = local.vm_configs
  
  # VM Configuration from YAML
  vm_name       = each.value.name
  vm_description = each.value.description
  catalog_name  = "Public Catalog"  # Use the correct catalog name
  template_name = each.value.template_name
  
  # Resource allocation from YAML
  cpus      = each.value.cpus
  cpu_cores = each.value.cpu_cores
  memory    = each.value.memory
  
  # Network configuration from YAML
  networks = [{
    type               = "org"
    name               = each.value.network_name
    ip_allocation_mode = each.value.ip_allocation_mode
    is_primary         = true
  }]
  
  # Customization from YAML
  admin_password = each.value.admin_password
  initscript     = each.value.initscript
  
  # Power management from YAML
  power_on = each.value.power_on
  
  # Metadata from YAML
  metadata = merge(local.common_tags, each.value.metadata)
  
  # Dependencies
  depends_on = [
    data.vcd_catalog_vapp_template.template,
    data.vcd_network_routed.network
  ]
}