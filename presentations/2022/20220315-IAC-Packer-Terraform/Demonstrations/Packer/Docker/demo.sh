#!/bin/bash

echo '> Packer build Docker image ...'
packer build .

echo '>  Start container...'

docker run -p 8000:80 -d  --name FRPSUG web

echo '>  Start Firefox ...'
firefox http://localhost:8000
