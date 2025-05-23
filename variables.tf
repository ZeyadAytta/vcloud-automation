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