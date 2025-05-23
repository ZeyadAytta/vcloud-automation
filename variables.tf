
# variables.tf - Root module variables
variable "vcd_user" {
  description = "vCloud Director username"
  type        = string
}

variable "vcd_password" {
  description = "vCloud Director password"
  type        = string
  sensitive   = true
}

variable "vcd_org" {
  description = "vCloud Director organization"
  type        = string
}

variable "vcd_vdc" {
  description = "vCloud Director VDC name"
  type        = string
}

variable "vcd_url" {
  description = "vCloud Director URL"
  type        = string
}

variable "vcd_max_retry_timeout" {
  description = "Maximum retry timeout for vCloud Director operations"
  type        = number
  default     = 60
}

variable "vcd_allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = false
}

variable "catalog_name" {
  description = "vCloud Director catalog name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "vcloud-infrastructure"
}

variable "virtual_machines" {
  description = "List of virtual machines to create"
  type = list(object({
    name                    = string
    description            = optional(string, "VM managed by Terraform")
    template_name          = string
    cpus                   = number
    cpu_cores              = optional(number, 1)
    memory                 = number
    storage_profile        = optional(string, "")
    disk_size_in_mb       = optional(number, 10240)
    network_name          = string
    ip_allocation_mode    = optional(string, "DHCP")
    ip_address           = optional(string)
    computer_name        = string
    admin_password       = optional(string)
    auto_generate_password = optional(bool, false)
    password_policy_enabled = optional(bool, true)
    power_on             = optional(bool, true)
    metadata             = optional(map(string), {})
    additional_disks     = optional(list(object({
      name            = string
      size_in_mb     = number
      bus_type       = optional(string, "SCSI")
      bus_sub_type   = optional(string, "lsilogicsas")
      storage_profile = optional(string, "")
    })), [])
  }))
  default = []
}