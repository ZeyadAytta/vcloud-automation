output "vm_id" {
  description = "ID of the created VM"
  value       = vcd_vm.vm.id
}

output "vm_name" {
  description = "Name of the created VM"
  value       = vcd_vm.vm.name
}

output "vm_ip_addresses" {
  description = "IP addresses of the VM"
  value       = vcd_vm.vm.network
}

output "vm_status" {
  description = "Status of the VM"
  value       = vcd_vm.vm.status
}

output "vm_href" {
  description = "HREF of the VM"
  value       = vcd_vm.vm.href
}