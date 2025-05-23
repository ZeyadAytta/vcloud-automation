data "vcd_catalog" "vm_catalog" {
  name = var.catalog_name
}

data "vcd_catalog_vapp_template" "vm_template" {
  catalog_id = data.vcd_catalog.vm_catalog.id
  name       = var.template_name
}

resource "vcd_vm" "vm" {
  name             = var.vm_name
  description      = var.vm_description
  vapp_template_id = data.vcd_catalog_vapp_template.vm_template.id
  
  cpus             = var.cpus
  cpu_cores        = var.cpu_cores
  memory           = var.memory
  
  power_on         = var.power_on
  
  # Network configuration
  dynamic "network" {
    for_each = var.networks
    content {
      type               = network.value.type
      name               = network.value.name
      ip_allocation_mode = lookup(network.value, "ip_allocation_mode", "POOL")
      ip                 = lookup(network.value, "ip", null)
      is_primary         = lookup(network.value, "is_primary", false)
    }
  }
  
  # Override template disk if custom size specified
  dynamic "override_template_disk" {
    for_each = var.disk_size != null ? [1] : []
    content {
      bus_type    = "paravirtual"
      size_in_mb  = var.disk_size
      bus_number  = 0
      unit_number = 0
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
  
  # Metadata - always add terraform created_by tag
  metadata_entry {
    key   = "created_by" 
    value = "terraform"
  }
  
  # Additional metadata from configuration
  dynamic "metadata_entry" {
    for_each = var.metadata
    content {
      key   = metadata_entry.key
      value = metadata_entry.value
    }
  }
}