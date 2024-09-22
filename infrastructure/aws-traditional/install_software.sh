#!/bin/ash

# This script runs as root via cloud-init
# It's intended to run on Alpine Linux

apk update || echo "Failed to update package list"

# install everything on all hosts, who cares
apk add docker go git wrk curl htop iotop vim || echo "Failed to install some packages"

# configure docker
usermod -a -G docker alpine
rc-update add docker default || echo "Failed to add docker to default runlevel"

# This will often fail due to a race with the rest of the system starting up.
# We usually get to the end of the script before services are ready to start.
# (* ERROR: cannot start docker as cgroups would not start)
service docker start || echo "Failed to start docker service"
