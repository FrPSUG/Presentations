#!/bin/bash

echo '> Remove Docker containers ...'
docker rm -f $(docker ps -a -q)

