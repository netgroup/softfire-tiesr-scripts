#!/bin/bash
# This script downloads the latest tcpdump which supports printing all fields of SRH icluding Segments_list
# The inner packet information is printed as well. 

#install dependencies 
apt-get -y update 
apt-get -y install libpcap-dev

# Download tcpdump 
git clone https://github.com/the-tcpdump-group/tcpdump

# Install tcpdump 
cd tcpdump && ./configure && make && make install && cd ..

