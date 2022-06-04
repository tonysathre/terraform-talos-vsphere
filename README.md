# Deploy a [Talos](https://github.com/siderolabs/talos) cluster on VMware vSphere

## Setup

Create secrets file

```powershell
@'
vsphere_server   = "vcenter.domain.com"
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "Passw0rd"
'@ | Out-File secrets.auto.tfvars
```

```
terraform init

terraform plan

terraform apply
```