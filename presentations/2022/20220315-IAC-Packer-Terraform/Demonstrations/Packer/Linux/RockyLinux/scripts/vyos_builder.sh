#!/bin/bash


#Clone Vyos-VM-images
echo '> Clonning vyos repository'
git clone https://github.com/vyos/vyos-vm-images.git

# Install update - ansible and python
sudo apt update
sudo apt install -y ansible python
