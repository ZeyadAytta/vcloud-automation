data "vcd_catalog" "vm_catalog" {
  name = var.catalog_name
}

data "vcd_catalog_vapp_template" "vm_template" {
  catalog_id = data.vcd_catalog.vm_catalog.id
  name       = var.template_name
}

# Create standalone VM (not in vApp)
resource "vcd_vm" "vm" {
  name               = var.vm_name
  description        = var.vm_description
  vapp_template_id   = data.vcd_catalog_vapp_template.vm_template.id
  
  cpus               = var.cpus
  cpu_cores          = var.cpu_cores
  memory             = var.memory
  
  power_on           = var.power_on
  
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
  
  # Guest customization for standalone VM
  customization {
    force                      = true
    change_sid                 = true
    allow_local_admin_password = true
    auto_generate_password     = false
    admin_password             = var.admin_password
    initscript                 = var.initscript
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