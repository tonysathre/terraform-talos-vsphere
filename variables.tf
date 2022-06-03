# vSphere
variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type      = string
  sensitive = true
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vsphere_datacenter" {
  type    = string
  default = "Ghostbit"
}

variable "vsphere_datastore" {
  type = list(string)
  default = [
    "vsanDatastore"
  ]
}

variable "vsphere_resource_pool" {
  type    = string
  default = "Resources"
}

variable "vsphere_folder" {
  type    = string
  default = "Kubernetes"
}

variable "vsphere_hosts" {
  type = list(string)
  default = [
    "esx1.ghostbit.org",
    "esx2.ghostbit.org",
    "esx3.ghostbit.org"
  ]
}

variable "vsphere_network" {
  type    = string
  default = "VM Network"
}

# Control Plane
variable "control_plane_count" {
  type    = number
  default = 1
}

variable "control_plane_num_cpus" {
  type    = number
  default = 2
}

variable "control_plane_memory" {
  type    = number
  default = 2048
}

# Workers
variable "worker_count" {
  type    = number
  default = 1
}

variable "worker_num_cpus" {
  type    = number
  default = 4
}

variable "worker_memory" {
  type    = number
  default = 4096
}

# Talos
variable "talos_installer_version" {
  type    = string
  default = "latest"
}

variable "kubelet_version" {
  type    = string
  default = "1.23.6"
}

variable "talos_vip_ip" {
  type    = string
  default = "10.0.0.40"
}

variable "remote_ovf_url" {
  type    = string
  default = "https://github.com/siderolabs/talos/releases/download/v1.0.4/vmware-amd64.ova"
}