output "vm_details" {
  description = "Details of created virtual machines"
  value = {
    for k, v in module.vcloud_vm : k => {
      id              = v.vm_id
      name            = v.vm_name
      status          = v.vm_status
      ip_address      = v.vm_ip_address
      computer_name   = v.computer_name
      href            = v.vm_href
    }
  }
}

output "vm_ids" {
  description = "Map of VM names to IDs"
  value = {
    for k, v in module.vcloud_vm : k => v.vm_id
  }
}

output "vm_ip_addresses" {
  description = "Map of VM names to IP addresses"
  value = {
    for k, v in module.vcloud_vm : k => v.vm_ip_address
  }
}
