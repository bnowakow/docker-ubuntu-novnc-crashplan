Vagrant.configure("2") do |config|
  # for some reason ssh key auth doesn't work on 22.04, using 20.04 instead
  #config.vm.box = "ubuntu/jammy64"
  config.vm.box = "bnowakow/nordvpn-torrent"
 
  config.disksize.size = '500GB'
 
  config.vm.network "private_network", ip: "192.168.10.148"
  config.vm.network :forwarded_port, guest: 6080, host: 6080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    # https://gist.github.com/shengslogar/979b79a4a1bfd4840f391119e7341efe
    vb.memory = 22048
    vb.cpus = 6
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "40"]
  end

# was in basebox

#  config.vm.provision "connect to nfs with manual workaround - /var/lib/docker", type: "shell", inline: <<-SHELL
#    mkdir -p /var/lib/docker;
#    mount -vvv -o vers=3 10.0.2.2:/mnt/MargokPool/home/sup/code/crashplan-docker/data/var_lib_docker /var/lib/docker
#  SHELL

  config.vm.provision "install docker", type: "shell", inline: <<-SHELL
    # https://docs.docker.com/engine/install/linux-postinstall/
    usermod -aG docker vagrant
  SHELL

# /was in basebox

  config.vm.provision "connect to nfs with manual workaround - archive", type: "shell", inline: <<-SHELL
    if [ ! -d "/mnt/MargokPool/archive" ]; then
        mkdir -p /mnt/MargokPool/archive
    fi
    if [ $(mount | grep "/mnt/MargokPool/archive" | wc -l) -gt 0 ]; then 
        umount /mnt/MargokPool/archive
    fi
    mount -vvv -o vers=3 10.0.2.2:/mnt/MargokPool/archive /mnt/MargokPool/archive
  SHELL

  # TODO do a function to do above and below
  config.vm.provision "connect to nfs with manual workaround - home", type: "shell", inline: <<-SHELL
    if [ ! -d "/mnt/MargokPool/home/sup" ]; then
        mkdir -p /mnt/MargokPool/home/sup
    fi
    if [ $(mount | grep "/mnt/MargokPool/home/sup" | wc -l) -gt 0 ]; then
        umount /mnt/MargokPool/home/sup
    fi
    mount -vvv -o vers=3 10.0.2.2:/mnt/MargokPool/home/sup /mnt/MargokPool/home/sup
  SHELL

  #config.vm.provision "file", source: ".", destination: "~/"

# TODO add shared dir for crashplan volume to be presisted
  config.vm.provision "configure transmission gui", type: "shell", inline: <<-SHELL
    cd /mnt/MargokPool/home/sup/code/crashplan-docker
    ./set-inotify-limits.sh
    docker compose up -d
  SHELL
    
  config.vm.provision "check when VNC will be started", type: "shell", inline: <<-SHELL
    cd /mnt/MargokPool/home/sup/code/crashplan-docker

    while true; do

        docker compose logs | grep "Listening on"
        if [ $? = 0 ]; then
            echo "VNC has started"
            exit;
        fi
        sleep 5;
    done
  SHELL

end
