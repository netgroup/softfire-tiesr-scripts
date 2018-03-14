#!/bin/bash

echo -e 'MYNAME="{{token_name}}"' > /etc/myhostid
echo -e 'MGMT={{token_ip_mgmt}}' >> /etc/myhostid
mkdir /home/ubuntu/tiesr

declare -a DOWNLOAD_FILES=(config2.sh load_cfg_file.sh vnfs_terms_setup.sh)
for MYFILE in ${DOWNLOAD_FILES[@]}; do
wget -O /home/ubuntu/tiesr/$MYFILE http://{{token_ip_mgmt}}:4000/static/softfire-tiesr-scripts/srv6router/$MYFILE
chmod +x /home/ubuntu/tiesr/$MYFILE
done

chown ubuntu:ubuntu -R /home/ubuntu/tiesr/