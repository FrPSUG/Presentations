#!/bin/bash -x

echo "Building TrueNas Appliance ..."

echo "Applying packer build to TrueNas.json ..."
packer build  -var-file=TrueNas-version.json TrueNas.json

