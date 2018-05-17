#!/bin/bash

##############################################################################################
# Copyright (C) 2018 Pier Luigi Ventre - (CNIT and University of Rome "Tor Vergata")
# Copyright (C) 2018 Stefano Salsano - (CNIT and University of Rome "Tor Vergata")
# www.uniroma2.it/netgroup - www.cnit.it
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# The script setups snort node
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

#echo $1
#./setup-snort.sh > $1-setup-snort.log 2>&1
#setup_snort > $1-setup-snort.log 2>&1

setup_snort () {
#Install dependencies
apt-get -y update
apt-get -y install libpcre3 libpcre3-dev gcc flex \
bison make libpcap-dev libdnet-dev libdumbnet-dev libpcre3-dev \
libghc-zlib-dev libnghttp2-dev

apt -y install automake
apt -y install libtool

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

