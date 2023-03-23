Vagrant.configure("2") do |config|
  # for some reason ssh key auth doesn't work on 22.04, using 20.04 instead
  #config.vm.box = "ubuntu/jammy64"
  config.vm.box = "bnowakow/nordvpn-torrent"
 
  config.disksize.size = '500GB'
 
  config.vm.network "private_network", ip: "192.168.10.148"
  config.vm.network :forwarded_port, guest: 80, host: 6080, auto_correct: true
  config.vm.network :forwarded_port, guest: 5901, host: 5901, auto_correct: true

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
        ln -sf /mnt/MargokPool/archive/ /mnt/Archive
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
        ln -sf /mnt/MargokPool/home/ /mnt/Home
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
    #docker compose up -d
  SHELL
    
 # config.vm.provision "check when VNC will be started", type: "shell", inline: <<-SHELL
 #   cd /mnt/MargokPool/home/sup/code/crashplan-docker
#
#    while true; do
#
#        docker compose logs | grep "Listening on"
#        if [ $? = 0 ]; then
#            echo "VNC has started"
#            exit;
#        fi
#        sleep 5;
#    done
#  SHELL

  config.vm.provision "dockerfile equivalent", type: "shell", inline: <<-SHELL
    # Avoid prompts for time zone
    export DEBIAN_FRONTEND noninteractive
    export TZ=Europe/Paris
    # Fix issue with libGL on Windows
    export LIBGL_ALWAYS_INDIRECT=1

    # built-in packages
    apt-get update && apt-get upgrade -y && apt-get install apt-utils -y \
    && apt-get install -y --no-install-recommends software-properties-common curl apache2-utils \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor nginx sudo net-tools zenity xz-utils \
        dbus-x11 x11-utils alsa-utils \
        mesa-utils libgl1-mesa-dri wget

    # install debs error if combine together
    apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        xvfb x11vnc \
        vim-tiny ttf-wqy-zenhei
    # DE not found: ttf-ubuntu-font-family

    apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        lxde gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme

    apt-get update && apt-get install -y python3 python3-tk gcc make cmake

    export TINI_VERSION=v0.19.0
    wget https://github.com/krallin/tini/archive/v0.19.0.tar.gz \
        && tar zxf v0.19.0.tar.gz \
        && export CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"; \
        cd tini-0.19.0; cmake . && make && make install \
        && cd ..; rm -r tini-0.19.0 v0.19.0.tar.gz

    # NextCloud
    apt-get update && apt-get install -y nextcloud-desktop

    # Firefox
    apt-get update && apt-get install -y firefox libpci3

    # Killsession app
    # TODO path
    cp -r /vagrant/killsession/ /tmp/killsession
    cd /tmp/killsession; \
    gcc -o killsession killsession.c && \
    mv killsession /usr/local/bin && \
    chmod a=rx /usr/local/bin/killsession && \
    chmod a+s /usr/local/bin/killsession && \
    mv killsession.py /usr/local/bin/ && chmod a+x /usr/local/bin/killsession.py && \
    mkdir -p /usr/local/share/pixmaps && mv killsession.png /usr/local/share/pixmaps/ && \
    mv KillSession.desktop /usr/share/applications/ && chmod a+x /usr/share/applications/KillSession.desktop && \
    cd /tmp && rm -r killsession

    # python library
    # TODO path
    cp /vagrant/rootfs/usr/local/lib/web/backend/requirements.txt /tmp/
    apt-get update \
    && dpkg-query -W -f='${Package}\n' > /tmp/a.txt \
    && apt-get install -y python3-pip python3-dev build-essential \
    && pip3 install setuptools wheel && pip3 install -r /tmp/requirements.txt \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && dpkg-query -W -f='${Package}\n' > /tmp/b.txt \
    && apt-get remove -y `diff --changed-group-format='%>' --unchanged-group-format='' /tmp/a.txt /tmp/b.txt | xargs` \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/* /tmp/a.txt /tmp/b.txt

    apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

    apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates gnupg patch

    # nodejs
    curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs

    # yarn
    # Fix issue with libssl and docker on M1 chips
    # RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    # TODO path
    cp /vagrant/yarnpkg_pubkey.gpg .
    cat yarnpkg_pubkey.gpg | apt-key add -  && rm yarnpkg_pubkey.gpg \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

    # build frontend
    # DR added to not have error
    mkdir /src
    # TODO path
    cp -r /vagrant/web /src/web
    cd /src/web \
    && yarn upgrade \
    && yarn \
    && yarn build
    sed -i 's#app/locale/#novnc/app/locale/#' /src/web/dist/static/novnc/app/ui.js

    apt autoremove && apt autoclean

    # DR added to not have error
    mkdir -p /usr/local/lib/web/
    cp -r /src/web/dist/ /usr/local/lib/web/frontend/
    # TODO path
    cp -r /vagrant/rootfs/* /
    ln -sf /usr/local/lib/web/frontend/static/websockify /usr/local/lib/web/frontend/static/novnc/utils/websockify && \
        chmod +x /usr/local/lib/web/frontend/static/websockify/run

    export HOME=/home/ubuntu
    export SHELL=/bin/bash

    #copy crashplan cert with chain
    # DR added to not have error
    mkdir -p /home/user
    # TODO path
    cp /vagrant/crashplan-chain-pem.crt /home/user/crashplan-chain-pem.crt

    /startup.sh

    # TODO path
    /vagrant/vnc.sh

SHELL

end
