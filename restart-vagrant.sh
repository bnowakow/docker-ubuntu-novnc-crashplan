#!/bin/bash

vagrant halt; vagrant destroy -f

# TODO check first if image already exists
#make build
#make push

vagrant up
vagrant port --guest 6080

