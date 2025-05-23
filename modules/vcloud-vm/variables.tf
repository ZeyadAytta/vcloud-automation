
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_description" {
  description = "Description of the VM"
  type        = string
  default     = "VM created by Terraform"
}

variable "catalog_name" {
  description = "Name of the catalog containing the template"
  type        = string
}

variable "template_name" {
  description = "Name of the template to use"
  type        = string
}

variable "memory" {
  description = "Memory allocation in MB"
  type        = number
}

variable "cpus" {
  description = "Number of CPUs"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores per CPU"
  type        = number
  default     = 1
}

variable "networks" {
  description = "List of networks to attach to the VM"
  type = list(object({
    type               = string
    name               = string
    ip_allocation_mode = optional(string)
    ip                 = optional(string)
    is_primary         = optional(bool)
  }))
}

variable "disk_size" {
  description = "Override template disk size in MB"
  type        = number
  default     = null
}

variable "power_on" {
  description = "Whether to power on the VM after creation"
  type        = bool
  default     = true
}

variable "customization" {
  description = "Guest customization settings"
  type        = map(any)
  default     = {}
}

variable "metadata" {
  description = "Metadata key-value pairs"
  type        = map(string)
  default     = {}
}
