resource "vcd_vapp" "vm_vapp" {
  name        = "${var.vm_name}-vapp"
  description = var.vm_description
  power_on    = false
}
resource "vcd_vapp_vm" "vm" {
  vapp_name     = vcd_vapp.vm_vapp.name
  name          = var.vm_name
  description   = var.vm_description
  catalog_name  = var.catalog_name
  template_name = var.template_name
  
  memory        = var.memory
  cpus          = var.cpus
  cpu_cores     = var.cpu_cores
  
  power_on      = var.power_on
  
  # Network configuration
  dynamic "network" {
    for_each = var.networks
    content {
      type               = network.value.type
      name               = network.value.name
      ip_allocation_mode = lookup(network.value, "ip_allocation_mode", "DHCP")
      ip                 = lookup(network.value, "ip", null)
      is_primary         = lookup(network.value, "is_primary", false)
    }
  }
  
  # Disk configuration
  dynamic "override_template_disk" {
    for_each = var.disk_size != null ? [var.disk_size] : []
    content {
      bus_type        = "paravirtual"
      size_in_mb      = override_template_disk.value
      bus_number      = 0
      unit_number     = 0
    }
  }
  
  # Guest customization
  dynamic "customization" {
    for_each = length(var.customization) > 0 ? [var.customization] : []
    content {
      force                      = lookup(customization.value, "force", false)
      change_sid                 = lookup(customization.value, "change_sid", false)
      allow_local_admin_password = lookup(customization.value, "allow_local_admin_password", false)
      auto_generate_password     = lookup(customization.value, "auto_generate_password", false)
      admin_password             = lookup(customization.value, "admin_password", null)
      number_of_auto_logons      = lookup(customization.value, "number_of_auto_logons", 0)
      join_domain                = lookup(customization.value, "join_domain", false)
      join_domain_name           = lookup(customization.value, "join_domain_name", null)
      join_domain_user           = lookup(customization.value, "join_domain_user", null)
      join_domain_password       = lookup(customization.value, "join_domain_password", null)
      join_domain_account_ou     = lookup(customization.value, "join_domain_account_ou", null)
      initscript                 = lookup(customization.value, "initscript", null)
    }
  }
  
  # Metadata
  metadata_entry {
    key   = "created_by"
    value = "terraform"
  }
  
  dynamic "metadata_entry" {
    for_each = var.metadata
    content {
      key   = metadata_entry.key
      value = metadata_entry.value
    }
  }
}
