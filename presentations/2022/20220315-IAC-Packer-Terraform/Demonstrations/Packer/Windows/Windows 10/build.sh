#!/bin/bash -x

echo "Building Windows 10 21H1 ..."

echo "Applying packer build to aseWindows10.json ..."
packer build -force -var-file=Windows10_21H1.json BaseWindows10.json 

