#!/bin/bash
# The script cleans SRv6Router node

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node clean                 ##"
echo "##                                                        ##"
echo "##        The clean process can last many minutes.        ##"
echo "##   Plase wait and do not interrupt the clean process.   ##"
echo "############################################################"

source /etc/myhostid

source load_cfg_file.sh 


echoeval () {
		echo "$@"
		eval "$@"
}

# Make sure only root can run our script
echo -e "\nChecking permission"
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as root\n" 1>&2
   exit 1
fi
echo -e "Ok!"

# $1=vnf1 $2=fd04:f1::fe $3=32 $4=fd04:f1::1 $5=eth0 $6=br0
lxd_container () {

VNF_NAME=$1
GW_IP=$2
NETMASK=$3
VNF_IP=$4
DEV_NAME=$5
BR_NAME=$6$1

#lxc network detach brvnf vnf1
echoeval lxc network detach $BR_NAME $VNF_NAME
#lxc network delete brvnf1 
echoeval lxc network delete $BR_NAME 
}

netns () {

VNF_NAME=$1
GW_IP=$2
NETMASK=$3
VNF_IP=$4
DEV_NAME=$5
BR_NAME=$6$1

#cleaning of namespace

}


source vnfs_terms_setup.sh



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
#cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf
rm /etc/quagga/zebra.conf
echo -e "\nReset of ospf6d.conf file"
#cp /usr/share/doc/quagga/examples/ospf6d.conf.sample /etc/quagga/ospf6d.conf
rm /etc/quagga/ospf6d.conf
echo -e "\nReset of vtysh.conf file"
if [ -f /etc/quagga/vtysh.conf ]; then
    rm /etc/quagga/vtysh.conf
fi

# Reset static routes
#declare -a remoteaddr
#declare -a interfaces
#counter=1
#endofcounter=$(($(route -n | grep UH | wc -l) + 1))
#while [ $counter -lt $endofcounter ]; do
#        arraycounter=$(($counter-1))
#        interfaces[$arraycounter]=$(route -n | grep UH | sed -n "$counter p" | awk '{split($0,a," "); print a[8]}')
#        remoteaddr[$arraycounter]=$(route -n | grep UH | sed -n "$counter p" | awk '{split($0,a," "); print a[1]}')
#		let counter=counter+1
#done

#echo -e "\nRemoving static routes"
#for (( i=0; i<${#interfaces[@]}; i++ )); do
#	route del -host ${remoteaddr[$i]} dev ${interfaces[$i]}
#done
#unset interfaces

# Deactivating unuseful interfaces (except management interface eth0) with ip link set ethX down
#unset interfaces
#declare -a interfaces
#counter=1
#endofcounter=$(($(ip link show | grep -e "eth[^0e]" | wc -l) + 1))
#while [ $counter -lt $endofcounter ]; do
#        arraycounter=$(($counter-1))
#        interfaces[$arraycounter]=$(ip link show | grep -e "eth[^0e]" | sed -n "$counter p" | awk '{split($0,a," "); print a[2]}' | awk '{split($0,a,"@"); print a[1]}')
#        let counter=counter+1
#done
#echo -e "\nDeactivating physical interfaces"
#for (( i=0; i<${#interfaces[@]}; i++ )); do
#	ip link set ${interfaces[$i]} down
#done

echo -e "\nRemoving loopback address"
ip addr del $(ip a show dev lo | grep "scope global" | awk '{split($0,a," "); print a[2]}') dev lo

# Clean VNFs and terminals
vnfs_terms_setup

#echo -e "\nRestarting network services"
#/etc/init.d/networking restart

echo -e "\nSRv6 Router node clean ended succesfully. Enjoy!\n"

EXIT_SUCCESS=0
exit $EXIT_SUCCESS
