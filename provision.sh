#!/bin/sh

if [ "$#" -le 0 ]
then
  SRC_DIR="/vagrant/"
else
  SRC_DIR="$1"
fi

apt-get update && apt-get install -y --force-yes \
  nginx \
  build-essential \
  ca-certificates \
  curl \
  git \
  libssl-dev \
  libxslt1-dev \
  module-init-tools \
  batctl \
  bridge-utils \
  openssh-server \
  openssl \
  perl \
  dnsmasq \
  squid3 \
  postgresql \
  procps \
  procps \
  python-psycopg2 \
  python-software-properties \
  software-properties-common \
  python \
  python-dev \
  python-pip \
  iproute \
  libnetfilter-conntrack3 \
  libevent-dev \
  ebtables \
  vim \
  tmux

modprobe nf_conntrack_netlink
modprobe nf_conntrack           
modprobe nfnetlink              
modprobe l2tp_netlink           
modprobe l2tp_core   

# Totally uneccessary fancy vim config
git clone git://github.com/maxb/vimrc.git /root/.vim_runtime
sh /root/.vim_runtime/install_awesome_vimrc.sh

# All exitnode file configs
cp -r $SRC_DIR/src/etc/* /etc/
cp -r $SRC_DIR/src/var/* /var/

pip install virtualenv

rm -rf /opt/tunneldigger # ONLY NECESSARY IF WE WANT TO CLEAN UP LAST TUNNELDIGGER INSTALL
git clone https://github.com/sudomesh/tunneldigger.git /opt/tunneldigger
cd /opt/tunneldigger/broker
virtualenv env_tunneldigger
/opt/tunneldigger/broker/bin/pip install -r requirements.txt

#
# cp /opt/tunneldigger/broker/scripts/tunneldigger-broker.init.d /etc/init.d @@TODO: Understand the difference between the two init scripts!
cp /opt/tunneldigger/broker/scripts/tunneldigger-broker.init.d /etc/init.d/tunneldigger

echo "host captive captive 127.0.0.1/32 md5" >> /etc/postgresql/9.1/main/pg_hba.conf 

modprobe batman-adv

cp $SRC_DIR/setupcaptive.sql /home/
cd /home
/etc/init.d/postgresql restart; su postgres -c "ls -la";su postgres -c "pwd"; su postgres -c "psql -f setupcaptive.sql -d postgres"

# Squid + redirect stuff for captive portal
# /etc/init.d/squid restart
# /etc/init.d/captive_portal_redirect start

# node stuffs
cp $SRC_DIR/.profile /root/.profile
mkdir /root/nvm
cd /root/nvm
usermod -d /root -m root
curl https://raw.githubusercontent.com/creationix/nvm/v0.10.0/install.sh | bash
cat /root/.profile
. /root/.profile; \
    nvm install 0.10; \
    nvm use 0.10;


# ssh stuffs
# @@TODO: BETTER PASSWORD/Public Key
echo 'root:sudoer' | chpasswd

alias ls="ls -la"

# nginx stuffs
cp $SRC_DIR/nginx.conf /etc/nginx/nginx.conf


