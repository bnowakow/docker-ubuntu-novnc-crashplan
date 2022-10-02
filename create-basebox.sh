#!/bin/bash

# TODO switch to git submodule instead
cp ../nordvpn-torrent/create-basebox.sh create-basebox-torrent.sh
cp ../nordvpn-torrent/Vagrantfile.basebox .

./create-basebox-torrent.sh

rm create-basebox-torrent.sh Vagrantfile.basebox

