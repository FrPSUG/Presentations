provider "vault" {
    address="http://127.0.0.1:8200"
    token="education"
}

provider "vsphere" {
    user           = data.vault_generic_secret.vcsaCreds.data["login"]
    password       = data.vault_generic_secret.vcsaCreds.data["mdp"]
    vsphere_server = "sco-labo-vcsa.ad.supalta.com"

    # If you have a self-signed cert
    allow_unverified_ssl = true
}
data "vault_generic_secret" "vcsaCreds" {
  path = "secret/VCSA"
}
variable "datacenter" {
    default = "Datacenter"
}
variable "cluster" {
    default = "SCO-LABO"
}
data "vsphere_datacenter" "dc" {
    name = var.datacenter
}
data "vsphere_compute_cluster" "compute_cluster" {
    name          = "SCO-LABO"
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "resource_pool" {
    depends_on = [
        vsphere_resource_pool.resource_pool
    ]
    name          = "RTR"
    datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_resource_pool" "resource_pool" {
    name                    = "RTR"
    parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}
data "vsphere_datastore" "datastore" {
    name          = "FREENAS1_VOL2"
    datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "parent" {
    path          = "RTR"
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.dc.id

}
data "vsphere_network" "network" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "lan" {
    name          = "G1_PPE_V1100"
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
    name          = "sco-labo-esx1.ad.supalta.com"
    datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vyos" {
    depends_on = [
      vsphere_folder.parent
    ]
    name                       = "RTR_SIO1"
    resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
    datastore_id               = data.vsphere_datastore.datastore.id
    datacenter_id              = data.vsphere_datacenter.dc.id
    host_system_id             = data.vsphere_host.host.id
    folder                     = "RTR"
    memory                     = 1024
    wait_for_guest_net_timeout = 0
    wait_for_guest_ip_timeout  = 0
    network_interface {
        network_id = data.vsphere_network.network.id
    }
    network_interface {
        network_id = data.vsphere_network.lan.id
    }

    ovf_deploy {
        local_ovf_path    = "/Storage/VMware/vyos-1.3.0.ova"
        disk_provisioning = "thin"
    }

    vapp {
        properties = {
        "password"  = "VMware1!",
        "user-data" = filebase64("${path.module}/user-data.yaml"),
        }
    }
    lifecycle {
        ignore_changes = [
        // it looks like some of the properties get deleted from the VM after it is deployed
        // just ignore them after the initial deployment
        vapp.0.properties,
        ]
    }
}