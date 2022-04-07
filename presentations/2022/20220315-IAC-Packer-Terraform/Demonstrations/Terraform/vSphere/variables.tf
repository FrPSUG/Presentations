variable "vm_names" {
    description = "ESXI name with the four Octet"
    default = {
        "ESXI1" = 81
        "ESXI2" = 82
        "ESXI3" = 83
        
    }
}
variable "groupe" {
    description = "Name for the Folder and ressource pool"
    type = string
    default = "G1"
}
variable "datacenter" {
    description = "Name for your Datacenter Object in your VMware vpShere Inventory"
    type = string
    default = "Datacenter"
}
variable "cluster" {
    description = "Name for your Cluster Object in your VMware vpShere Inventory"
    type = string
    default = "SCO-LABO"
}
variable "datastore" {
    description = "Name for your DataStore Object in your VMware vpShere Inventory"
    type = string
    default = "FREENAS1_VOL2"
}
variable "network" {
    description = "Name for your Network Object in your VMware vpShere Inventory: web Access"
    type = string
    default ="VM Network"
}
variable "trunk" {
    description = "Name for your Network Object in your VMware vpShere Inventory: Trunk "
    type = string
    default ="VM Network"
}
variable "iSCSI" {
    description = "Name for your Network Object in your VMware vpShere Inventory: iSCSI "
    type = string
    default ="ISCSI_G1"
}
variable "LAN" {
    description = "Name for your Network Object in your VMware vpShere Inventory: LAN "
    type = string
    default ="E20_V1179"
}
variable "vcsa" {
    description = "VCSA FQDN"
    type = string
    default ="sco-labo-esx1.ad.supalta.com"
}
variable "vcsarootp" {
    description = "VCSA root Password"
    type = string
    default ="VMware123!"
}
variable "vcsaAdminp" {
    description = "Password for Administrator@vsphere.local"
    type = string
    default ="VMware123!"
}

variable "esxi-ram" {
    description = "ESXI RAM"
    type = number
    default =   8192
}
variable "DomainName" {
    description = "Name for your LAB"
    type = string
    default = "vExpert.lab"
}
variable "network-address" {
    description = "Network Address"
    type = string
    default = "10.0.0"
}
variable "network-gateway" {
    description = "Gateway Address"
    type = string
    default = "10.0.0.254"
}
variable "network-dnsserver" {
    description = "DNS server Address"
    type = string
    default = "10.0.0"
}
variable "esxi-password" {
    description = "Esxi root password"
    type = string
    default = "VMware1!"
}
variable "esxinumber" {
    description = "How many ESXI in my Lab"
    type = string
    default = "8"
}
variable "DNS-Layout" {
    description = "Keyboard Layout in DNS Server fr/us"
    type = string
    default = "fr"
}
variable "DNS-Hostname" {
    description = "The hostname for the DNS Server"
    type = string
    default = "DNSSRV"
}
variable "DNS-password" {
    description = "Root Password for the DNS Server"
    type = string
    default = "VMware1!"
}
variable "vm-client" {
    description = "Name VM Client"
    type = string
    default = "Client"
}

variable "ClientC" {
    description = "Number of Client Ubuntu VM"
    type = number
    default = 1
}
variable "Clientcpu" {
    description = "Number CPU for Ubuntu Client"
    type = number
    default = 2
}
variable "Clientram" {
    description = "Number RAM for Ubuntu Client"
    type = number
    default = 4096
}
variable "Clientguestid" {
    description = "Ubuntu VM guest"
    type = string
    default = "ubuntu64Guest"
}

