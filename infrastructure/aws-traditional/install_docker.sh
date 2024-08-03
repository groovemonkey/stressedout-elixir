#!/bin/bash

# install everything on all hosts, who cares
doas apk add docker go git wrk curl htop iotop vim

# configure docker
doas rc-update add docker default
doas service docker start

