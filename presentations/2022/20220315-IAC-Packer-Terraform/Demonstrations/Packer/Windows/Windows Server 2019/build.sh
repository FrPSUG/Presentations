#!/bin/bash -x

echo "Building Windows Server 2019 GUI ..."

echo "Applying packer build to BaseWindowsServer.json ..."
packer build  -var-file=WindowsServer2019GUI.json BaseWindowsServer.json

