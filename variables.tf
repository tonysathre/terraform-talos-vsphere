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
  default = 3
}

variable "control_plane_machine_network_hostnames" {
  type = list(string)
  default = [
    "talos-controlplane-1",
    "talos-controlplane-2",
    "talos-controlplane-3"
  ]
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
  default = 4
}

variable "worker_machine_network_hostnames" {
  type = list(string)
  default = [
    "talos-worker-1",
    "talos-worker-2",
    "talos-worker-3",
    "talos-worker-4"
  ]
}

variable "worker_num_cpus" {
  type    = number
  default = 4
}

variable "worker_memory" {
  type    = number
  default = 8192
}

# Talos
variable "cluster_name" {
  type    = string
  default = "talos"
}

variable "talos_installer_version" {
  type    = string
  default = "latest"
}

variable "talos_vip_ip" {
  type    = string
  default = "10.0.0.40"
}

variable "talos_version" {
  type    = string
  default = "1.0.4"
}

variable "kubernetes_version" {
  type    = string
  default = "1.23.6"
}
