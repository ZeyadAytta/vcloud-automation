# VMware vCloud Director Terraform Module

This Terraform configuration creates and manages virtual machines in VMware vCloud Director using YAML-based configuration files. It supports both Linux and Windows VMs with customizable resource allocation, networking, and metadata.

## 🚀 Features

- **YAML-driven configuration** - Define VMs in simple YAML files
- **Standalone VM deployment** - Creates VMs outside of vApps
- **Multi-OS support** - Linux and Windows templates
- **Flexible networking** - Support for multiple network configurations
- **Guest customization** - Post-deployment scripts and configurations
- **Metadata tagging** - Automatic and custom metadata assignment
- **Modular design** - Reusable Terraform modules

## 📁 Project Structure

```
├── locals.tf                    # Local values and YAML parsing
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Root module variables
├── providers.tf                 # Provider configuration
├── outputs.tf                   # Output definitions
├── terraform.tfvars             # Variable values (customize this)
├── versions.tf                  # Terraform version constraints
├── modules/
│   └── vcloud-vm/              # VM creation module
│       ├── main.tf             # VM resource definitions
│       ├── variables.tf        # Module variables
│       ├── outputs.tf          # Module outputs
│       └── versions.tf         # Module version constraints
├── vcloud-tasks/
│   └── createvm.yaml           # VM configuration file
└── README.md                   # This file
```

## 🔧 Prerequisites

- **Terraform** >= 1.0
- **VMware vCloud Director** access with appropriate permissions
- **Valid vCD credentials** with VM creation rights
- **Network access** to vCloud Director API endpoint

## ⚙️ Configuration

### 1. Update Connection Details

Edit `terraform.tfvars` with your vCloud Director details:

```hcl
# vCloud Director connection details
vcd_user     = "your-username"
vcd_password = "your-password"
vcd_org      = "your-organization"
vcd_vdc      = "your-vdc-name"
vcd_url      = "https://your-vcd-url.com/api"
vcd_max_retry_timeout = 60
vcd_allow_unverified_ssl = false

# Environment settings
environment = "test"
project_name = "vcloud-standalone-vms"
```

### 2. Configure VMs

Edit `vcloud-tasks/createvm.yaml` to define your VMs:

```yaml
vms:
  - name: "web-server-01"
    description: "Production web server"
    catalog_name: "Public Catalog"
    template_name: "Centos-8 Template"
    memory: 4096
    cpus: 2
    cpu_cores: 1
    power_on: true
    networks:
      - type: "org"
        name: "Production-Network"
        ip_allocation_mode: "POOL"
        is_primary: true
    customization:
      change_sid: false
      admin_password: "SecurePassword123!"
      initscript: |
        #!/bin/bash
        yum update -y
        yum install -y nginx
        systemctl enable nginx
        systemctl start nginx
    metadata:
      Environment: "Production"
      Owner: "WebTeam"
      OS: "Linux"
```

## 🚀 Deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan Deployment

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

### 4. View Outputs

```bash
terraform output
```

## ��️ VM Configuration Options

### Linux VM Example

```yaml
- name: "linux-vm"
  description: "Linux server"
  catalog_name: "Public Catalog"
  template_name: "Centos-8 Template"
  memory: 4096
  cpus: 2
  cpu_cores: 1
  power_on: true
  networks:
    - type: "org"
      name: "VLAN-10"
      ip_allocation_mode: "POOL"
      is_primary: true
  customization:
    change_sid: false              # Linux doesn't need SID change
    admin_password: "Password123!"
    initscript: |
      #!/bin/bash
      yum update -y
      yum install -y htop vim curl
  metadata:
    Environment: "Dev"
    OS: "Linux"
```

### Windows VM Example

```yaml
- name: "windows-vm"
  description: "Windows server"
  catalog_name: "Public Catalog"
  template_name: "Windows-Server-2019"
  memory: 8192
  cpus: 2
  cpu_cores: 2
  power_on: true
  networks:
    - type: "org"
      name: "VLAN-10"
      ip_allocation_mode: "POOL"
      is_primary: true
  customization:
    change_sid: true               # Windows needs SID change
    admin_password: "ComplexPass123!"
    initscript: |
      # PowerShell script
      Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
      Set-TimeZone -Id "UTC"
  metadata:
    Environment: "Dev"
    OS: "Windows"
```

## 🔄 Guest Customization

### Current Status
Guest customization is **commented out** by default due to potential API compatibility issues. To enable:

### For Linux VMs
In `modules/vcloud-vm/main.tf`, uncomment the Linux customization block:

```hcl
customization {
  force                      = false
  change_sid                 = false
  allow_local_admin_password = true
  auto_generate_password     = false
  admin_password             = var.admin_password
  initscript                 = var.initscript
}
```

### For Windows VMs
In `modules/vcloud-vm/main.tf`, uncomment the Windows customization block:

```hcl
customization {
  force                      = true
  change_sid                 = true
  allow_local_admin_password = true
  auto_generate_password     = false
  admin_password             = var.admin_password
  number_of_auto_logons      = 1
  join_domain                = false
}
```

## 🌐 Network Configuration

### IP Allocation Modes
- **POOL** - Automatic IP from network pool
- **DHCP** - DHCP assigned IP
- **MANUAL** - Manually specified IP (requires `ip` field)

### Example with Static IP
```yaml
networks:
  - type: "org"
    name: "Production-Network"
    ip_allocation_mode: "MANUAL"
    ip: "192.168.1.100"
    is_primary: true
```

## 📊 Outputs

The module provides the following outputs:

- **vm_details** - Complete VM information including IDs, names, status, and IP addresses
- **vm_ids** - Map of VM names to their vCloud Director IDs

Access outputs:
```bash
# View all VM details
terraform output vm_details

# View specific VM ID
terraform output vm_ids
```

## 🏷️ Metadata and Tags

### Automatic Tags
All VMs automatically receive these metadata tags:
- `created_by: terraform`
- `Environment: <from variables>`
- `Project: <from variables>`
- `ManagedBy: Terraform`
- `CreatedDate: <timestamp>`

### Custom Metadata
Add custom metadata in the YAML configuration:
```yaml
metadata:
  Environment: "Production"
  Owner: "WebTeam"
  Application: "WordPress"
  BackupSchedule: "Daily"
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Catalog Not Found
```
Error: catalog 'Public Catalog' not found in org 'Your-Org'
```
**Solution**: Verify catalog name and organization. For shared catalogs, ensure the `org` parameter is correctly set in the data source.

#### 2. Template Not Found
```
Error: template 'Template-Name' not found
```
**Solution**: Check available templates in your catalog through vCloud Director web interface.

#### 3. Guest Customization Errors
```
Error: XML syntax error... guest customization
```
**Solution**: Guest customization is commented out by default. Enable gradually and test with your specific templates.

#### 4. Network Access Issues
```
Error: network 'Network-Name' not found
```
**Solution**: Verify network name exists in your VDC and is accessible.

### Debug Mode

Enable Terraform debug logging:
```bash
export TF_LOG=DEBUG
terraform plan
```

## �� Security Considerations

### Sensitive Data
- Store passwords in environment variables or use Terraform Cloud/Vault
- Enable `.tfvars` files in `.gitignore`
- Use encrypted state storage for production

### Example with Environment Variables
```bash
export TF_VAR_vcd_password="your-secure-password"
terraform apply
```

## 📝 Customization Guide

### Adding More VMs
Simply add more VM definitions to `vcloud-tasks/createvm.yaml`:

```yaml
vms:
  - name: "vm-1"
    # ... configuration
  - name: "vm-2"
    # ... configuration
  - name: "vm-3"
    # ... configuration
```

### Modifying Resources
Update resource allocation in YAML:
```yaml
memory: 8192        # 8GB RAM
cpus: 4             # 4 vCPUs
cpu_cores: 2        # 2 cores per CPU
```

### Different Templates
Use different templates per VM:
```yaml
# Linux VM
template_name: "Centos-8 Template"

# Windows VM  
template_name: "Windows-Server-2019"

# Ubuntu VM
template_name: "Ubuntu-20.04-LTS"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Terraform and vCloud Director documentation
3. Open an issue with detailed error messages and configuration

## 📚 Additional Resources

- [VMware vCloud Director Documentation](https://docs.vmware.com/en/VMware-Cloud-Director/)
- [Terraform vCD Provider Documentation](https://registry.terraform.io/providers/vmware/vcd/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

---

**Made with ❤️ for VMware vCloud Director automation**
