#!/bin/bash

#echo $1
#./setup-snort.sh > $1-setup-snort.log 2>&1
#setup_snort > $1-setup-snort.log 2>&1

setup_snort () {
#Install dependencies
apt-get -y --force-yes update
apt-get -y --force-yes install libpcre3 libpcre3-dev gcc flex \
bison make libpcap-dev libdnet-dev libdumbnet-dev libpcre3-dev \
libghc-zlib-dev libnghttp2-dev

apt install automake
apt install libtool

# Install daq
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
tar xvzf daq-2.0.6.tar.gz
cd daq-2.0.6/
./configure && make && sudo make install && cd ..

# Install libpcap
git clone https://github.com/the-tcpdump-group/libpcap
cd libpcap/
./configure
make install && cd ..

echo -e "\n****** INSTALLING SNORT"

# Install snort
rm -rf conf-snort

git clone https://bitbucket.org/amsalam20/snort/
cd snort/snort-2.9.11.1/
./configure && make && sudo make install && cd ../../
ldconfig

echo -e "\n****** GET  SNORT CONFIG FILES"

# Get snort configuration files
git clone https://bitbucket.org/amsalam20/conf-snort/

# Add snort configuration
mkdir /etc/snort/ /etc/snort/rules /var/log/snort/
touch /var/log/snort/alert
cp conf-snort/local.rules /etc/snort/rules/local.rules
cp conf-snort/snort.conf /etc/snort/snort.conf

}

setup_snort > $1-setup-snort.log 2>&1

