#!/bin/bash

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
#    echo -n "$VNC_PASSWORD" | vncpasswd -f > /.passwordvnc
    chmod 400 /.password*
    export VNC_PASSWORD=
# else
#     echo -n "ubuntu" | vncpasswd -f > /.passwordvnc
#     chmod 400 /.passwordvnc
fi

if [ -n "$X11VNC_ARGS" ]; then
    sed -i "s/^command=x11vnc.*/& ${X11VNC_ARGS}/" /etc/supervisor/conf.d/supervisord.conf
fi

if [ -n "$OPENBOX_ARGS" ]; then
    sed -i "s#^command=/usr/bin/openbox.*#& ${OPENBOX_ARGS}#" /etc/supervisor/conf.d/supervisord.conf
fi

if [ -n "$RESOLUTION" ]; then
    sed -i "s/1024x768/$RESOLUTION/" /usr/local/bin/xvfb.sh
fi

USER=${USERNAME:-root}
HOME=/root
if [ "$USER" != "root" ]; then
    echo "* enable custom user: $USER"
    if [ -z "$PASSWORD" ]; then
        echo "  set default password to \"ubuntu\""
        PASSWORD=ubuntu
    fi
    echo "  Password set to $PASSWORD"
    UIDOPT=""
    UIDVAL=""
    if [ -z "$USERID" ]; then
        echo "  user id in container may not match user id on host"
    else
        echo "  setting user id to $USERID"
        UIDOPT="--non-unique --uid"
        UIDVAL=$USERID
    fi
    useradd --create-home --skel /root --shell /bin/bash --user-group --groups adm,sudo $UIDOPT $UIDVAL $USER
    HOME=/home/$USER
    echo "$USER:$PASSWORD" | chpasswd
    cp -r /root/{.profile,.bashrc,.config,.gtkrc-2.0,.gtk-bookmarks} ${HOME}
    if [ -r "/root/.novnc_setup" ]; then
      source /root/.novnc_setup
    fi
    chown -R $USER:$USER ${HOME}
    [ -d "/dev/snd" ] && chgrp -R adm /dev/snd
fi
sed -i -e "s|%USER%|$USER|" -e "s|%HOME%|$HOME|" /etc/supervisor/conf.d/supervisord.conf

# home folder
if [ ! -x "$HOME/.config/pcmanfm/LXDE/" ]; then
    mkdir -p $HOME/.config/pcmanfm/LXDE/
    ln -sf /usr/local/share/doro-lxde-wallpapers/desktop-items-0.conf $HOME/.config/pcmanfm/LXDE/
    chown -R $USER:$USER $HOME
fi

# nginx workers
sed -i 's|worker_processes .*|worker_processes 1;|' /etc/nginx/nginx.conf

# nginx ssl
if [ -n "$SSL_PORT" ] && [ -e "/etc/nginx/ssl/nginx.key" ]; then
    echo "* enable SSL"
	sed -i 's|#_SSL_PORT_#\(.*\)443\(.*\)|\1'$SSL_PORT'\2|' /etc/nginx/sites-enabled/default
	sed -i 's|#_SSL_PORT_#||' /etc/nginx/sites-enabled/default
fi

# nginx http base authentication
if [ -n "$HTTP_PASSWORD" ]; then
    echo "* enable HTTP base authentication"
    htpasswd -bc /etc/nginx/.htpasswd $USER $HTTP_PASSWORD
	sed -i 's|#_HTTP_PASSWORD_#||' /etc/nginx/sites-enabled/default
fi

# dynamic prefix path renaming
if [ -n "$RELATIVE_URL_ROOT" ]; then
    echo "* enable RELATIVE_URL_ROOT: $RELATIVE_URL_ROOT"
	sed -i 's|#_RELATIVE_URL_ROOT_||' /etc/nginx/sites-enabled/default
	sed -i 's|_RELATIVE_URL_ROOT_|'$RELATIVE_URL_ROOT'|' /etc/nginx/sites-enabled/default
fi

# Check for files in /etc/startup/ that should be sourced
# to customize the Docker image
for stsrc in /etc/startup/*.sh; do
  if [ -r $stsrc ]; then
  	source $stsrc
  fi
done

# clearup
PASSWORD=
HTTP_PASSWORD=

add-apt-repository ppa:openjdk-r/ppa

apt-get update
apt-get install -y openjdk-11-jdk
apt-get install -y wget cpio libxss1 gnome-system-monitor vim less

cd /etc/ssl/certs/java
keytool -import -keystore cacerts -file $HOME/crashplan-chain-pem.crt -storepass changeit -noprompt
echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/bin"' >> /etc/environment
echo 'LD_LIBRARY_PATH="/usr/lib/jvm/java-11-openjdk-amd64/lib/server"' >> /etc/environment

if [[ ! -d "/usr/local/crashplan/bin" ]]; then

    cd $HOME
    # https://support.crashplan.com/hc/en-us/articles/11427606025997
    # when updating CrashPlan version 1. update below url 2. make build 3. make push 4. update version of image in docker-compose.yml
    wget https://download.crashplan.com/installs/agent/cloud/11.0.1/33/install/CrashPlanSmb_11.0.1_33_Linux.tgz
    tar zxf CrashPlanSmb*.tgz
    cd crashplan-install
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n" | ./install.sh
fi

# java mx: 19000m

/usr/local/crashplan/bin/service.sh start

#TINI_SUBREAPER="" exec /usr/local/bin/tini -- supervisord -n -c /etc/supervisor/supervisord.conf
service nginx stop
# https://www.onurguzel.com/supervisord-restarting-and-reloading/
service supervisor stop
ps -ef | grep supervisord
supervisord -n -c /etc/supervisor/supervisord.conf &
# as non-root user:
#su vagrant -c "x11vnc -display :1 -xkb -forever -shared -repeat -capslock &" # 1. for some reason running as root (maybe it's from supervisor) 2. for some reason can't connect via VNC and have to run this line manually from vagrant user
