output "vm_id" {
  description = "ID of the created VM"
  value       = vcd_vapp_vm.vm.id
}

output "vm_name" {
  description = "Name of the created VM"
  value       = vcd_vapp_vm.vm.name
}

output "vm_ip_addresses" {
  description = "IP addresses of the VM"
  value       = vcd_vapp_vm.vm.network
}

output "vm_status" {
  description = "Status of the VM"
  value       = vcd_vapp_vm.vm.status
}

output "vapp_name" {
  description = "Name of the vApp containing the VM"
  value       = vcd_vapp.vm_vapp.name
}