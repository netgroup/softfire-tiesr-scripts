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
# The script cleans SRv6Router node
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it>

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node clean                 ##"
echo "##                                                        ##"
echo "##        The clean process can last many minutes.        ##"
echo "##   Plase wait and do not interrupt the clean process.   ##"
echo "############################################################"

# Make sure only root can run our script
echo -e "\nChecking permission"
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as root\n" 1>&2
   exit 1
fi
echo -e "Ok!"

# Reset tunnels
if [ $(ip link show | grep tap | wc -l) -gt 0 ]; then
	echo -e "\nTurning off tap interfaces"
	declare -a tap
	counter=1
	endofcounter=$(($(ip link show | grep tap | wc -l) + 1))
	while [ $counter -lt $endofcounter ]; do
			arraycounter=$(($counter-1))
			tap[$arraycounter]=$(ip link show | grep tap | sed -n "$counter p" | awk '{split($0,a," "); print a[2]}' | awk '{split($0,a,":"); print a[1]}')
			let counter=counter+1
	done
	for (( i=0; i<${#tap[@]}; i++ )); do
		ip link set ${tap[$i]} down
		ip link del ${tap[$i]}
	done
fi
if [ $(ps aux | grep openvpn | wc -l) -gt 1 ]; then
	echo -e "\nTurning off OpenVPN service"
	pkill openvpn
fi
echo -e "\nRemoving configuration files"
rm /etc/openvpn/*.conf 2> /dev/null
rm /etc/openvpn/*.sh 2> /dev/null

# Reset of Quagga
if [ $(ps aux | grep quagga | wc -l) -gt 1 ]
  then
	echo -e "\nTurning off Quagga service"
	pkill zebra
	pkill ospf6d
fi
echo -e "\nReset of zebra.conf file"
cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf
echo -e "\nReset of ospf6d.conf file"
cp /usr/share/doc/quagga/examples/ospf6d.conf.sample /etc/quagga/ospf6d.conf
echo -e "\nReset of vtysh.conf file"
if [ -f /etc/quagga/vtysh.conf ]; then
    rm /etc/quagga/vtysh.conf
fi

# Reset static routes
declare -a remoteaddr
declare -a interfaces
counter=1
endofcounter=$(($(route -n | grep UH | wc -l) + 1))
while [ $counter -lt $endofcounter ]; do
        arraycounter=$(($counter-1))
        interfaces[$arraycounter]=$(route -n | grep UH | sed -n "$counter p" | awk '{split($0,a," "); print a[8]}')
        remoteaddr[$arraycounter]=$(route -n | grep UH | sed -n "$counter p" | awk '{split($0,a," "); print a[1]}')
		let counter=counter+1
done

echo -e "\nRemoving static routes"
for (( i=0; i<${#interfaces[@]}; i++ )); do
	route del -host ${remoteaddr[$i]} dev ${interfaces[$i]}
done
unset interfaces

# Deactivating unuseful interfaces (except management interface eth0) with ip link set ethX down
unset interfaces
declare -a interfaces
counter=1
endofcounter=$(($(ip link show | grep -e "eth[^0e]" | wc -l) + 1))
while [ $counter -lt $endofcounter ]; do
        arraycounter=$(($counter-1))
        interfaces[$arraycounter]=$(ip link show | grep -e "eth[^0e]" | sed -n "$counter p" | awk '{split($0,a," "); print a[2]}' | awk '{split($0,a,"@"); print a[1]}')
        let counter=counter+1
done
echo -e "\nDeactivating physical interfaces"
for (( i=0; i<${#interfaces[@]}; i++ )); do
	ip link set ${interfaces[$i]} down
done

echo -e "\nRemoving loopback address"
ip addr del $(ip a show dev lo | grep "scope global" | awk '{split($0,a," "); print a[2]}') dev lo

echo -e "\nRestarting network services"
/etc/init.d/networking restart

echo -e "\nSRv6 Router node clean ended succesfully. Enjoy!\n"

EXIT_SUCCESS=0
exit $EXIT_SUCCESS
