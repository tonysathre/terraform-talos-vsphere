provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

module "kubernetes-cluster" {
  source  = "ilpozzd/vsphere-cluster/talos"
  version = "1.1.2"

  datacenter     = var.vsphere_datacenter
  datastores     = var.vsphere_datastore
  hosts          = var.vsphere_hosts
  resource_pool  = var.vsphere_resource_pool
  folder         = var.vsphere_folder
  remote_ovf_url = "https://github.com/siderolabs/talos/releases/download/v${var.talos_version}/vmware-amd64.ova"

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
      image = "ghcr.io/siderolabs/kubelet:v${var.kubernetes_version}"
      extraArgs = {
        node-labels = "openebs.io/engine=mayastor"
      }
      extraMounts = [{
        destination = "/var/local"
        type        = "bind"
        source      = "/var/local"
        options = [
          "rbind",
          "rshared",
          "rw"
        ]
      }]
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

  control_plane_disks = [{
    label            = "root"
    size             = 10
    thin_provisioned = false
    eagerly_scrub    = true
  }]

  control_plane_network_interfaces = [{
    name = var.vsphere_network
  }]

  control_plane_machine_network_hostnames = [
    "talos-controlplane-1",
    "talos-controlplane-2",
    "talos-controlplane-3"
  ]

  control_plane_machine_cert_sans = [
    [
      "talos.ghostbit.org",
      "${var.talos_vip_ip}"
    ]
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
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
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
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
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
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
      }
    ]
  ]

  # Workers
  worker_count    = var.worker_count
  worker_num_cpus = var.worker_num_cpus
  worker_memory   = var.worker_memory

  worker_disks = [
    {
      label            = "root"
      size             = 10
      thin_provisioned = false
    },
    {
      label            = "storage"
      size             = 40
      thin_provisioned = false
      eagerly_scrub    = true
    }
  ]

  worker_network_interfaces = [
    {
      name = var.vsphere_network
    }
  ]

  worker_machine_extra_configuration = {
    sysctls = {
      "vm.nr_hugepages" = "2048"
    }
  }

  worker_machine_network_hostnames = [
    "talos-worker-1",
    "talos-worker-2",
    "talos-worker-3",
    "talos-worker-4"
  ]

  worker_machine_cert_sans = [
    [
      "talos.ghostbit.org",
      "${var.talos_vip_ip}"
    ]
  ]

  worker_machine_network_interfaces = [
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.41/24"
        ]
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.42/24"
        ]
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.43/24"
        ]
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
      }
    ],
    [
      {
        interface = "eth0"
        addresses = [
          "10.0.0.44/24"
        ]
        routes = [{
          network = "0.0.0.0/0"
          gateway = "10.0.0.1"
        }]
      }
    ]
  ]

  cluster_name = "talos"
  cluster_inline_manifests = [
    {
      name     = "namespace-mayastor"
      contents = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          name: mayastor
        EOT
    },
    {
      name     = "mayastor-pool-worker-1"
      contents = <<-EOT
      apiVersion: "openebs.io/v1alpha1"
      kind: MayastorPool
      metadata:
        name: pool-worker-1
        namespace: mayastor
      spec:
        node: talos-worker-1
        disks: ["/dev/sdb"]
      EOT
    },
    {
      name     = "mayastor-pool-worker-2"
      contents = <<-EOT
      apiVersion: "openebs.io/v1alpha1"
      kind: MayastorPool
      metadata:
        name: pool-worker-2
        namespace: mayastor
      spec:
        node: talos-worker-2
        disks: ["/dev/sdb"]
      EOT
    },
    {
      name     = "mayastor-pool-worker-3"
      contents = <<-EOT
      apiVersion: "openebs.io/v1alpha1"
      kind: MayastorPool
      metadata:
        name: pool-worker-3
        namespace: mayastor
      spec:
        node: talos-worker-3
        disks: ["/dev/sdb"]
      EOT
    },
    {
      name     = "mayastor-pool-worker-4"
      contents = <<-EOT
      apiVersion: "openebs.io/v1alpha1"
      kind: MayastorPool
      metadata:
        name: pool-worker-4
        namespace: mayastor
      spec:
        node: talos-worker-4
        disks: ["/dev/sdb"]
      EOT
    }
  ]

  cluster_extra_manifests = [
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/operator-rbac.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/mayastorpoolcrd.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/nats-deployment.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/etcd/storage/localpv.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/etcd/statefulset.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/etcd/svc.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/etcd/svc-headless.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/csi-daemonset.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/core-agents-deployment.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/rest-deployment.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/rest-service.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/csi-deployment.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor-control-plane/master/deploy/msp-deployment.yaml",
    "https://raw.githubusercontent.com/openebs/mayastor/master/deploy/mayastor-daemonset.yaml"
  ]

  kubeconfig_path       = "C:\\Users\\Tony\\.kube\\config"
  talosconfig_path      = "C:\\Users\\Tony\\.talos\\config"
  validity_period_hours = 18760
}