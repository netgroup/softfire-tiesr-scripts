#!/bin/bash

echo -e 'MYNAME="{{token_name}}"' > /etc/myhostid
echo -e 'MGMT={{token_ip_mgmt}}' >> /etc/myhostid
mkdir /home/ubuntu/tiesr
wget -O /home/ubuntu/tiesr/config2.sh http://{{token_ip_mgmt}}:4000/static/softfire-tiesr-scripts/srv6router/config2.sh
chmod +x /home/ubuntu/tiesr/config2.sh
chown ubuntu:ubuntu -R /home/ubuntu/tiesr/