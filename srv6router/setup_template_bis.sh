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
# The script setups scripts on a machine
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

echo -e 'MYNAME="{{token_name}}"' > /etc/myhostid
echo -e 'MGMT={{token_ip_mgmt}}' >> /etc/myhostid
mkdir /home/ubuntu/tiesr

declare -a DOWNLOAD_FILES=(config2.sh load_cfg_file.sh vnfs_terms_setup.sh)
for MYFILE in ${DOWNLOAD_FILES[@]}; do
wget -O /home/ubuntu/tiesr/$MYFILE http://{{token_ip_mgmt}}:4000/static/softfire-tiesr-scripts/srv6router/$MYFILE
chmod +x /home/ubuntu/tiesr/$MYFILE
done

chown ubuntu:ubuntu -R /home/ubuntu/tiesr/