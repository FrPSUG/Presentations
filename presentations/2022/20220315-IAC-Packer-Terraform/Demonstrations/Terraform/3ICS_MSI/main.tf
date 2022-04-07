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
data "vsphere_datacenter" "dc" {
    name = var.datacenter
}
data "vsphere_compute_cluster" "compute_cluster" {
    name          = var.cluster
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
    name          = var.datastore
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "resource_pool" {
    depends_on = [
        vsphere_resource_pool.resource_pool
    ]
    name          = "3ICS_MSI"
    datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "parent" {
    path          = "3ICS_MSI"
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.dc.id

}
resource "vsphere_resource_pool" "resource_pool" {
    name                    = "3ICS_MSI"
    parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}
data "vsphere_network" "network" {
    name          = var.network
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "lan" {
    name          = var.LAN
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
    name          = var.vcsa
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
    name          = "vcsa_ref"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "Template_Lubuntu3ICS" {
    name = "/Datacenter/vm/Templates/Lubuntu_3ICS"
    datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vyos" {
    depends_on = [
        vsphere_folder.parent
    ]
    name                       = "RTR_MSI_3ICS"
    resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
    datastore_id               = data.vsphere_datastore.datastore.id
    datacenter_id              = data.vsphere_datacenter.dc.id
    host_system_id             = data.vsphere_host.host.id
    folder                     = vsphere_folder.parent.path
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
        local_ovf_path    = "/Storage/VMware/vyos.ova"
        disk_provisioning = "thin"
    }

    vapp {
        properties = {
        "password"  = "VMware1!",
        "user-data" = filebase64("${path.module}/vyos/user-data.yaml"),
        }
    }
    lifecycle {
        ignore_changes = all
    }
}

resource "vsphere_virtual_machine" "Lubuntu_3ICS" {
        depends_on = [
        vsphere_folder.parent,
        vsphere_virtual_machine.vyos,
    ]
    count                = var.ClientC
    name                 = "${var.vm-client}_${count.index + 1}_${var.groupe}"
    folder               = vsphere_folder.parent.path
    resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
    datastore_id         = data.vsphere_datastore.datastore.id
    num_cpus             = var.Clientcpu
    memory               = var.Clientram
    guest_id             = var.Clientguestid
    network_interface {
        network_id = data.vsphere_network.lan.id
    }

disk {
    label = "${var.vm-client}-${count.index + 1}-disk"
    size  = 40
}
clone {
    template_uuid = data.vsphere_virtual_machine.Template_Lubuntu3ICS.id
    }
}
data "vsphere_role" "role1" {
    label = "Administrator"
}

data "vsphere_folder" "folders" {
    path = "${vsphere_folder.parent.path}"
    depends_on = [
            vsphere_folder.parent
    ]
}

resource "vsphere_entity_permissions" "Permissions" {
    entity_id = data.vsphere_folder.folders.id
    entity_type = "Folder"
    permissions {
        user_or_group = "SUPALTA\\chics1"
        propagate = true
        is_group = true
        role_id = data.vsphere_role.role1.id
    }
}