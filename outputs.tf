output "vm_details" {
  description = "Details of created VMs"
  value = {
    for k, v in module.vcloud_vms : k => {
      name         = v.vm_name
      id           = v.vm_id
      ip_addresses = v.vm_ip_addresses
      status       = v.vm_status
    }
  }
}