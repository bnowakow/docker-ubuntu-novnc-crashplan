#!/bin/bash

vagrant up;
vagrant provision
vagrant ssh -c "/vagrant/vnc.sh"
echo
echo please remember to run /vagrant/desktop-crashplan.sh while logged in VNC

