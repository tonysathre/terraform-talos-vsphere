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

  # Base Machine Config
  machine_base_configuration = {
    install = {
      disk       = "/dev/sda"
      image      = "ghcr.io/siderolabs/installer:${var.talos_installer_version}"
      bootloader = true
      wipe       = false
    }
    time = {
      disabled = false
      servers = [
        "time.cloudflare.com"
      ]
      bootTimeout = "2m0s"
    }
    features = {
      rbac = true
    }
    kubelet = {
      image = "ghcr.io/siderolabs/kubelet:v${var.kubelet_version}"
      extraArgs = {
        node-labels = "openebs.io/engine=mayastor"
      }
      # extraMounts = [{
      #   type        = "bind"
      #   source      = "/var/local"
      #   destination = "/var/local"
      #   options = [
      #     "rbind",
      #     "rshared",
      #     "rw"
      #   ]
      # }]
    }
  }

  machine_network = {
    nameservers = [
      "10.0.0.5",
      "10.0.0.6"
    ]
  }

  # Control Plane
  control_plane_count    = var.control_plane_count
  control_plane_num_cpus = var.control_plane_num_cpus
  control_plane_memory   = var.control_plane_memory

  control_plane_disks = [
    {
      label = "root"
      size  = 20
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

  control_plane_machine_cert_sans = [
    ["talos.ghostbit.org", "${var.talos_vip_ip}"]
  ]

  control_plane_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        vip = {
          ip = var.talos_vip_ip
        }
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
        vip = {
          ip = var.talos_vip_ip
        }
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
        vip = {
          ip = var.talos_vip_ip
        }
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

  # Workers
  worker_count    = var.worker_count
  worker_num_cpus = var.worker_num_cpus
  worker_memory   = var.worker_memory

  worker_disks = [
    {
      label = "root"
      size  = 20
    },
    {
      label = "storage"
      size  = 40
    }
  ]

  worker_machine_extra_configuration = {
    sysctls = {
      "vm.nr_hugepages" = "1024"
    }
    # disks = [{
    #   device = "/dev/sdb"
    #   partitions = [{
    #     mountpoint = "/var/mnt/extra"
    #     size       = "40 GB"
    #   }]
    # }]
  }

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

  worker_machine_cert_sans = [
    ["talos.ghostbit.org", "${var.talos_vip_ip}"]
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
            gateway = "10.0.0.1"
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

  cluster_name = "talos"
  cluster_inline_manifests = [{
    name = "namespace-mayastor"
    contents = <<-EOT
      apiVersion: v1
      kind: Namespace
      metadata:
        name: mayastor
      EOT
  }]

  kubeconfig_path       = "./configs/kubeconfig"
  talosconfig_path      = "./configs/talosconfig"
  validity_period_hours = 18760
}