Vagrant.configure("2") do |config|
  # for some reason ssh key auth doesn't work on 22.04, using 20.04 instead
  #config.vm.box = "ubuntu/jammy64"
  config.vm.box = "bnowakow/nordvpn-torrent"
  
  config.vm.network "private_network", ip: "192.168.10.148"
  config.vm.network :forwarded_port, guest: 6080, host: 6080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    # https://gist.github.com/shengslogar/979b79a4a1bfd4840f391119e7341efe
    vb.memory = 12048
    vb.cpus = 4
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "40"]
  end

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision "connect to nfs with manual workaround", type: "shell", inline: <<-SHELL
    mkdir -p /mnt/MargokPool/archive
    mount -vvv -o vers=3 10.0.2.2:/mnt/MargokPool/archive /mnt/MargokPool/archive
  SHELL

  #config.vm.provision "file", source: ".", destination: "~/"

# TODO add shared dir for crashplan volume to be presisted
  config.vm.provision "configure transmission gui", type: "shell", inline: <<-SHELL
    cd /vagrant
    # TODO make sure that image is being pulled, not built from source
    docker compose up -d
  SHELL
    
  config.vm.provision "check when VNC will be started", type: "shell", inline: <<-SHELL
    cd /vagrant

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
