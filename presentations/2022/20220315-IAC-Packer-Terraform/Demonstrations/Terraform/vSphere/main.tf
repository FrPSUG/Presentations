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
    name          = "vSphereLab_${var.groupe}"
    datacenter_id = data.vsphere_datacenter.dc.id
}
resource "vsphere_folder" "parent" {
    path          = "vSphereLab_${var.groupe}"
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.dc.id

}
resource "vsphere_resource_pool" "resource_pool" {
    name                    = "vSphereLab_${var.groupe}"
    parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}
data "vsphere_network" "network" {
    name          = var.network
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "Trunk" {
    name          = var.trunk
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "ISCSI" {
    name          = var.iSCSI
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
data "vsphere_virtual_machine" "templateclient" {
    name = "/Datacenter/vm/Templates/UbuntuD-2101"
    datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "NestedESXI" {
    depends_on = [
        vsphere_virtual_machine.DNS,
        vsphere_folder.parent
    ]
    for_each         = var.vm_names
    name             = "${each.key}_${var.groupe}"
    resource_pool_id = data.vsphere_resource_pool.resource_pool.id
    datastore_id     = data.vsphere_datastore.datastore.id
    datacenter_id    = data.vsphere_datacenter.dc.id
    host_system_id   = data.vsphere_host.host.id
    folder           = vsphere_folder.parent.path
    firmware         = "efi"
    memory                      = var.esxi-ram
    num_cpus                    = 2
    num_cores_per_socket        = 4 
    nested_hv_enabled           = true
    cpu_hot_add_enabled         = true
    cpu_hot_remove_enabled      = true
    wait_for_guest_net_timeout  = 0
    wait_for_guest_ip_timeout   = 0
    network_interface {
        network_id = data.vsphere_network.lan.id
    }
    network_interface {
        network_id = data.vsphere_network.lan.id
    }
        network_interface {
        network_id = data.vsphere_network.Trunk.id
    }

        network_interface {
        network_id = data.vsphere_network.ISCSI.id
    }

    ovf_deploy {
        local_ovf_path    = "/Storage/VMware/Nested_ESXi7.0u2a_Appliance_Template_v1.ova"
        disk_provisioning = "thin"
        ip_protocol          = "IPV4"
        ip_allocation_policy = "STATIC_MANUAL"
        ovf_network_map = {
        "VM Network" = "${data.vsphere_network.lan.id}"
        }
    }

    vapp {
        properties = {
        "guestinfo.hostname"  = "${each.key}.${var.DomainName}",
        "guestinfo.ipaddress" = "${var.network-address}.${each.value}",
        "guestinfo.netmask"   = "255.255.255.0",
        "guestinfo.gateway"   = "${var.network-gateway}",
        "guestinfo.dns"       = "${var.network-dnsserver}",
        "guestinfo.domain"    = "${var.DomainName}",
        "guestinfo.ntp"       = "pool.ntp.org",
        "guestinfo.password"  = "${var.esxi-password}",
        "guestinfo.ssh"       = "True"
        }
    }
    lifecycle {
            ignore_changes = all
        }
    }
resource "vsphere_virtual_machine" "DNS" {
    depends_on = [
        vsphere_virtual_machine.vyos,
        vsphere_folder.parent
    ]
    name             = "DNSSRV_${var.groupe}"
    resource_pool_id = data.vsphere_resource_pool.resource_pool.id
    datastore_id     = data.vsphere_datastore.datastore.id
    datacenter_id    = data.vsphere_datacenter.dc.id
    host_system_id   = data.vsphere_host.host.id
    folder           = vsphere_folder.parent.path

    memory                     = 1024
    wait_for_guest_net_timeout = 0
    wait_for_guest_ip_timeout  = 0
    network_interface {
        network_id = data.vsphere_network.lan.id
    }

    ovf_deploy {
        local_ovf_path    = "/Storage/VMware/PhotonOS_DNS_Appliance_0.2.2.ova"
        disk_provisioning = "thin"
        ovf_network_map = {
        "VM Network" = data.vsphere_network.lan.id
        }
    }

    vapp {
        properties = {
        "guestinfo.esxiname"       = "ESXI",
        "guestinfo.domain"         = "${var.DomainName}",
        "guestinfo.esxinumber"     = var.esxinumber,
        "guestinfo.keyboardlayout" = var.DNS-Layout,
        "guestinfo.network"        = var.network-address,
        "guestinfo.ipaddress"      = "${var.network-address}.100",
        "guestinfo.hostname"       = var.DNS-Hostname,
        "guestinfo.netmask"        = "24",
        "guestinfo.root_password"  = var.DNS-password,
        "guestinfo.gateway"        = var.network-gateway
        }
    }
    lifecycle {
            ignore_changes = all
        }
    }

resource "vsphere_virtual_machine" "vyos" {
    depends_on = [
        vsphere_folder.parent
    ]
    name                       = "RTR_Lab_${var.groupe}"
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
    network_interface {
        network_id = data.vsphere_network.ISCSI.id
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
resource "vsphere_virtual_machine" "vcsa" {
    depends_on = [
        vsphere_virtual_machine.DNS,
        vsphere_virtual_machine.vyos
    ]
    name                        = "vcsa_Lab_${var.groupe}"
    resource_pool_id            = data.vsphere_resource_pool.resource_pool.id
    datastore_id                = "${data.vsphere_datastore.datastore.id}"
    num_cpus                    = "${data.vsphere_virtual_machine.template.num_cpus}"
    memory                      = "${data.vsphere_virtual_machine.template.memory}"
    guest_id                    = "${data.vsphere_virtual_machine.template.guest_id}"
    scsi_type                   = "${data.vsphere_virtual_machine.template.scsi_type}"
    folder                       = vsphere_folder.parent.path
    scsi_controller_count = 2
    network_interface {
    network_id                  = data.vsphere_network.lan.id
    adapter_type                = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }

    disk {
    label = "disk0"
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
    unit_number = 0
    }
    disk {
    label = "disk1"
    size = "${data.vsphere_virtual_machine.template.disks.1.size}"
    unit_number = 1

    }
    disk {
    label = "disk2"
    size = "25"
    unit_number = 2
    }
    disk {
    label = "disk3"
    size = "50"
    unit_number = 3
    }
    disk {
    label = "disk4"
    size = "10"
    unit_number = 4

    }
    disk {
    label = "disk5"
    size = "10"
        unit_number = 5

    }
    disk {
    label = "disk6"
    size = "15"
        unit_number = 6

    }
    disk {
    label = "disk7"
    size = "25"
        unit_number = 7

    }
    disk {
    label = "disk8"
    size = "1"
        unit_number = 8
    }

    disk {
    label = "disk9"
    size = "10"
        unit_number = 9

    }

    disk {
    label = "disk10"
    size = "10"
        unit_number = 10

    }
    disk {
    label = "disk11"
    size = "100"
        unit_number = 11

    }
    disk {
    label = "disk12"
    size = "50"
        unit_number = 12

    }
    disk {
    label = "disk13"
    size = "25"
        unit_number = 13

    }
    disk {
    label = "disk14"
    size = "15"
        unit_number = 14

    }
        disk {
    label = "disk15"
    size = "100"
        unit_number = 15

    }


    clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    }

    annotation = "vcsa Lab"

    vapp {
    properties = {
        "domain": "${var.DomainName}",
        "guestinfo.cis.ad.domain-name": "",
        "guestinfo.cis.ad.domain.password": "",
        "guestinfo.cis.ad.domain.username": "",
        "guestinfo.cis.appliance.net.addr": "${var.network-address}.80",
        "guestinfo.cis.appliance.net.addr.family": "ipv4",
        "guestinfo.cis.appliance.net.dns.servers": "${var.network-address}.100",
        "guestinfo.cis.appliance.net.gateway": "${var.network-address}.254",
        "guestinfo.cis.appliance.net.mode": "static",
        "guestinfo.cis.appliance.net.pnid": "vcsa.${var.DomainName}",
        "guestinfo.cis.appliance.net.ports": "",
        "guestinfo.cis.appliance.net.prefix": "24",
        "guestinfo.cis.appliance.ntp.servers": "0.pool.ntp.org",
        "guestinfo.cis.appliance.root.passwd": "${var.vcsarootp}",
        "guestinfo.cis.appliance.root.shell": "",
        "guestinfo.cis.appliance.ssh.enabled": "True",
        "guestinfo.cis.appliance.time.tools-sync": "False",
        "guestinfo.cis.ceip_enabled": "False",
        "guestinfo.cis.clientlocale": "",
        "guestinfo.cis.db.instance": "",
        "guestinfo.cis.db.password": "",
        "guestinfo.cis.db.provider": "",
        "guestinfo.cis.db.servername": "",
        "guestinfo.cis.db.serverport": "",
        "guestinfo.cis.db.type": "embedded",
        "guestinfo.cis.db.user": "",
        "guestinfo.cis.deployment.autoconfig": "True",
        "guestinfo.cis.deployment.node.type": "embedded",
        "guestinfo.cis.feature.states": "",
        "guestinfo.cis.netdump.enabled": "",
        "guestinfo.cis.silentinstall": "",
        "guestinfo.cis.system.vm0.hostname": "vcsa.${var.DomainName}",
        "guestinfo.cis.system.vm0.port": "",
        "guestinfo.cis.upgrade.import.directory": "",
        "guestinfo.cis.upgrade.source.export.directory": "",
        "guestinfo.cis.upgrade.source.guest.password": "",
        "guestinfo.cis.upgrade.source.guest.user": "",
        "guestinfo.cis.upgrade.source.guestops.host.addr": "",
        "guestinfo.cis.upgrade.source.guestops.host.password": "",
        "guestinfo.cis.upgrade.source.guestops.host.user": "",
        "guestinfo.cis.upgrade.source.ma.port": "",
        "guestinfo.cis.upgrade.source.platform": "",
        "guestinfo.cis.upgrade.source.ssl.thumbprint": "",
        "guestinfo.cis.upgrade.source.vpxd.ip": "",
        "guestinfo.cis.upgrade.source.vpxd.password": "",
        "guestinfo.cis.upgrade.source.vpxd.user": "",
        "guestinfo.cis.upgrade.user.options": "",
        "guestinfo.cis.vmdir.domain-name": "vsphere.local",
        "guestinfo.cis.vmdir.first-instance": "True",
        "guestinfo.cis.vmdir.password": "${var.vcsaAdminp}",
        "guestinfo.cis.vmdir.replication-partner-hostname": "",
        "guestinfo.cis.vmdir.site-name": "default-first-site",
        "guestinfo.cis.vmdir.username": "administrator@vsphere.local",
        "guestinfo.cis.vpxd.mac-allocation-scheme.prefix": "",
        "guestinfo.cis.vpxd.mac-allocation-scheme.prefix-length": "",
        "guestinfo.cis.vpxd.mac-allocation-scheme.ranges": "",
        "searchpath": "${var.DomainName}",
        "vmname": "vcenter-server-applaince"
        }
    }
    lifecycle {
        ignore_changes = all
    }
}
resource "vsphere_virtual_machine" "TrueNas" {
    depends_on = [
        vsphere_folder.parent,
        vsphere_virtual_machine.vyos
    ]
    name                       = "TrueNas_Lab_${var.groupe}"
    resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
    datastore_id               = data.vsphere_datastore.datastore.id
    datacenter_id              = data.vsphere_datacenter.dc.id
    host_system_id             = data.vsphere_host.host.id
    folder                     = vsphere_folder.parent.path
    scsi_type                  = "lsilogic"
    memory                     = 8192
    num_cpus                   = 2
    wait_for_guest_net_timeout = 0
    wait_for_guest_ip_timeout  = 0
    network_interface {
        network_id = data.vsphere_network.ISCSI.id
    }
    ovf_deploy {
        local_ovf_path    = "/Storage/VMware/TrueNas-Appliance-12U8.ova"
        disk_provisioning = "thin"
    }
        lifecycle {
        ignore_changes = all
    }

}

resource "vsphere_virtual_machine" "Client" {
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
    network_interface {
        network_id = data.vsphere_network.ISCSI.id
    }

disk {
    label = "${var.vm-client}-${count.index + 1}-disk"
    size  = 25
}
clone {
    template_uuid = data.vsphere_virtual_machine.templateclient.id
    }
}
