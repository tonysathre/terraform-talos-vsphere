provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

module "kubernetes-cluster" {
  source  = "ilpozzd/vsphere-cluster/talos"
  version = "1.1.0"

  datacenter     = var.vsphere_datacenter
  datastores     = var.vsphere_datastore
  hosts          = var.vsphere_hosts
  resource_pool  = var.vsphere_resource_pool
  folder         = var.vsphere_folder
  remote_ovf_url = var.remote_ovf_url

  control_plane_count    = var.control_plane_count
  control_plane_num_cpus = var.control_plane_num_cpus
  control_plane_memory   = var.control_plane_memory
  control_plane_disks = [
    {
      label            = "sda"
      size             = 20
      eagerly_scrub    = false
      thin_provisioned = true
    }
  ]
  control_plane_network_interfaces = [
    {
      name = var.vsphere_network
    }
  ]

  control_plane_machine_network_hostnames = [
    "talos-controlplane-1",
    "talos-controlplane-2",
    "talos-controlplane-3"
  ]

  worker_count    = var.worker_count
  worker_num_cpus = var.worker_num_cpus
  worker_memory   = var.worker_memory
  worker_disks = [
    {
      label            = "sda"
      size             = 40
      eagerly_scrub    = false
      thin_provisioned = true
    }
  ]
  worker_network_interfaces = [
    {
      name = var.vsphere_network
    }
  ]

  worker_machine_network_hostnames = [
    "talos-worker-1",
    "talos-worker-2",
    "talos-worker-3",
    "talos-worker-4"
  ]

  machine_base_configuration = {
    install = {
      disk       = "/dev/sda"
      image      = "ghcr.io/siderolabs/installer:latest"
      bootloader = true
      wipe       = false
    }
    time = {
      disabled = false
      servers = [
        "0.ntp pool.ntp.org"
      ]
      bootTimeout = "2m0s"
    }
    features = {
      rbac = true
    }
  }

  machine_network = {
    nameservers = [
      "10.0.0.5",
      "10.0.0.6"
    ]
  }

  control_plane_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.31/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.32/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.33/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ]
  ]

  worker_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.41/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "192.168.10.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.42/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.43/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.44/24"
        ]
        routes = [
          {
            network = "0.0.0.0/0"
            gateway = "10.0.0.1"
          }
        ]
      }
    ]
  ]

  cluster_name     = "talos"
  kubeconfig_path  = "./configs/kubeconfig"
  talosconfig_path = "./configs/talosconfig"
}