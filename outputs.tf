output "vm_details" {
  description = "Details of created virtual machines"
  value = {
    for k, v in module.vcloud_vm : k => {
      id            = v.vm_id
      name          = v.vm_name
      status        = v.vm_status
      ip_addresses  = v.vm_ip_addresses
      href          = v.vm_href
    }
  }
}

output "vm_ids" {
  description = "Map of VM names to IDs"
  value = {
    for k, v in module.vcloud_vm : k => v.vm_id
  }
}