# terraform-talos-vsphere

## Setup

```
talosctl gen config talos https://talos.ghostbit.org --dns-domain ghostbit.org --output-dir configs

terraform init

terraform plan

terraform apply
```