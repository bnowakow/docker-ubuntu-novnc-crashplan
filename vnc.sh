#!/bin/bash

sudo su - vagrant -c "cd /home/vagrant; x11vnc -display :1 -xkb -forever -shared -repeat -capslock &"
