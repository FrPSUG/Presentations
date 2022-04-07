terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 1.25.0"
    }
  }
  required_version = ">= 0.13"
}
