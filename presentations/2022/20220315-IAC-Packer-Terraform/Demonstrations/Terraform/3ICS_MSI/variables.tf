variable "groupe" {
    description = "Name for the Folder and ressource pool"
    type = string
    default = "3ICS"
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
variable "LAN" {
    description = "Name for your Network Object in your VMware vpShere Inventory: LAN "
    type = string
    default ="ICS_E2_2002"
}
variable "vcsa" {
    description = "VCSA FQDN"
    type = string
    default ="sco-labo-esx1.ad.supalta.com"
}
variable "vm-client" {
    description = "Name VM Client"
    type = string
    default = "Lubuntu"
}

variable "ClientC" {
    description = "Number of Client Ubuntu VM"
    type = number
    default = 40
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

