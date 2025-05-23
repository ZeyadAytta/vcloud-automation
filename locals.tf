locals {
  # Load VM configuration from YAML file
  vm_config = yamldecode(file("${path.root}/vcloud-tasks/createvm.yaml"))
}