module "vcloud_vms" {
  source = "./modules/vcloud-vm"
  
  for_each = { for vm in local.vm_config.vms : vm.name => vm }
  
  # VM Configuration
  vm_name           = each.value.name
  vm_description    = lookup(each.value, "description", "VM created by Terraform")
  catalog_name      = each.value.catalog_name
  template_name     = each.value.template_name
  
  # Resource Configuration
  memory            = each.value.memory
  cpus              = each.value.cpus
  cpu_cores         = lookup(each.value, "cpu_cores", 1)
  
  # Network Configuration
  networks          = each.value.networks
  
  # Storage Configuration
  disk_size         = lookup(each.value, "disk_size", null)
  
  # Power Configuration
  power_on          = lookup(each.value, "power_on", true)
  
  # Customization
  customization     = lookup(each.value, "customization", {})
  metadata          = lookup(each.value, "metadata", {})
}