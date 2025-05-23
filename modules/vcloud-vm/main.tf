data "vcd_catalog" "vm_catalog" {
  name = var.catalog_name
  org  = "Templates"  #Specify in which org template exists
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
 ## Guest customization for standalone VM - simplified for Linux
 # customization {
 #   force                      = false
 #   change_sid                 = false
 #   allow_local_admin_password = true
 #   auto_generate_password     = false
 #   admin_password             = var.admin_password
 #   initscript                 = var.initscript
 # }
  

 # Guest customization - Windows (commented out - uncomment for Windows VMs)
  # customization {
  #   force                      = true
  #   change_sid                 = true
  #   allow_local_admin_password = true
  #   auto_generate_password     = false
  #   admin_password             = var.admin_password
  #   number_of_auto_logons      = 1
  #   join_domain                = false
  #   # For domain join (optional):
  #   # join_domain                = true
  #   # join_domain_name           = "your-domain.com"
  #   # join_domain_user           = "domain-admin-user"
  #   # join_domain_password       = "domain-admin-password"
  #   # join_domain_account_ou     = "OU=Computers,DC=your-domain,DC=com"
  #   # Windows initialization script (PowerShell):
  #   # initscript                 = <<-EOT
  #   #   # Install IIS
  #   #   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
  #   #   # Install Chocolatey
  #   #   Set-ExecutionPolicy Bypass -Scope Process -Force
  #   #   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  #   #   iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  #   #   # Install software via Chocolatey
  #   #   choco install googlechrome firefox -y
  #   # EOT
  # }
    
  # Metadata - always add terraform created_by tag
  metadata_entry {
    key           = "created_by"
    value         = "terraform"
    type          = "MetadataStringValue"
    user_access   = "READWRITE"
    is_system     = false
  }
  
  # Additional metadata from configuration
  dynamic "metadata_entry" {
    for_each = var.metadata
    content {
      key           = metadata_entry.key
      value         = metadata_entry.value
      type          = "MetadataStringValue"
      user_access   = "READWRITE"
      is_system     = false
    }
  }
}