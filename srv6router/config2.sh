#!/bin/bash
# The script configures SRv6Router node

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node config                ##"
echo "##                                                        ##"
echo "##       The config process can last many minutes.        ##"
echo "##   Plase wait and do not interrupt the config process.  ##"
echo "############################################################"

source /etc/myhostid

source load_cfg_file.sh

#INTERF_NAME="eth0"
# Address of the management server
# the addredss of the management server now is in /etc/myhostid
#MGMT=172.17.0.1

QUAGGA_PATH="/usr/sbin"
#QUAGGA_PATH="/usr/lib/quagga"
RANGE_FOR_AREA_0="fd00::/8"

echoeval () {
		echo "$@"
		eval "$@"
}


# Setup properly IPv6
ipv6_setup() {
  echo -e "\nConfiguring IPv6"
  # Enable IPv6 forwarding
  sysctl -w net.ipv6.conf.all.forwarding=1
  sysctl -w net.ipv6.conf.all.seg6_enabled=1
  sysctl -w net.ipv6.conf.all.accept_ra=0

  for i in ${TAP[@]}; do
    # Enable IPv6 forwarding
    sysctl -w net.ipv6.conf.$i.forwarding=1
    # Enable Seg6
    sysctl -w net.ipv6.conf.$i.seg6_enabled=1
    # Disable accept RA
    sysctl -w net.ipv6.conf.$i.accept_ra=0
  done
}

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
#lxc network create brvnf1 ipv6.address=fd04:f1::fe/32 ipv4.address=none
echoeval lxc network create $BR_NAME ipv6.address=$GW_IP/$NETMASK ipv4.address=none
#lxc network attach brvnf1 vnf1 eth0
echoeval lxc network attach $BR_NAME $VNF_NAME $DEV_NAME
#lxc exec vnf1 -- ip -6 a a  fd04:f1::1/32 dev eth0
echoeval lxc exec $VNF_NAME -- ip -6 a a  $VNF_IP/$NETMASK dev $DEV_NAME
#lxc exec vnf1 -- ip -6 r a default via fd04:f1::fe dev eth0
echoeval lxc exec $VNF_NAME -- ip -6 r a default via $GW_IP dev $DEV_NAME
#lxc exec vnf1 -- ip link set dev eth0 up
echoeval lxc exec $VNF_NAME -- ip link set dev $DEV_NAME up
#lxc exec vnf1 -- sysctl -w net.ipv6.conf.all.forwarding=1
echoeval lxc exec $VNF_NAME -- sysctl -w net.ipv6.conf.all.forwarding=1
#lxc exec vnf1 -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
echoeval lxc exec $VNF_NAME -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
#lxc exec vnf1 -- sysctl -w net.ipv6.conf.eth0.seg6_enabled=1
echoeval lxc exec $VNF_NAME -- sysctl -w net.ipv6.conf.${DEV_NAME}.seg6_enabled=1
#sudo ip link set dev vnfbr1 up
echoeval sudo ip link set dev $BR_NAME up
}


netns () {
VNF_NAME=$1
GW_IP=$2
NETMASK=$3
VNF_IP=$4
DEV_NAME=$5
BR_NAME=$6$1
echoeval ip netns add ${VNF_NAME}
echoeval ip link add ${BR_NAME} type veth peer name ${DEV_NAME}
echoeval ip link set ${DEV_NAME} netns ${VNF_NAME}
echoeval ifconfig ${BR_NAME} up
echoeval ip netns exec ${VNF_NAME} ifconfig ${DEV_NAME} up
echoeval ip netns exec ${VNF_NAME} sysctl -w net.ipv6.conf.all.forwarding=1
echoeval ip -6 addr add ${GW_IP}/${NETMASK} dev ${BR_NAME}
echoeval ip netns exec ${VNF_NAME} ip -6 addr add ${VNF_IP}/${NETMASK} dev ${DEV_NAME}
echoeval ip netns exec ${VNF_NAME} ip -6 route add default via ${GW_IP}
echoeval ip netns exec ${VNF_NAME} sysctl -w net.ipv6.conf.all.forwarding=1
echoeval ip netns exec ${VNF_NAME} sysctl -w net.ipv6.conf.all.seg6_enabled=1
echoeval ip netns exec ${VNF_NAME} sysctl -w net.ipv6.conf.${DEV_NAME}.seg6_enabled=1
}


source vnfs_terms_setup.sh

# Create quagga setup
quagga_setup() {
  echo -e "\nConfiguring Quagga"
  # Generate the proper config for the vtysh
  echo "!
!service integrated-vtysh-config
hostname $MYNAME
username root $ROUTERPWD
!" > /etc/quagga/vtysh.conf

  # Do not display end of sign after each command
  VTYSH_PAGER=more > /etc/environment

  # Let's finally start the daemons
  echo -e "\nStarting Zebra"
  $QUAGGA_PATH/zebra -d
  echo -e "\nStarting Ospf6d"
  $QUAGGA_PATH/ospf6d -d
}

# Create ospf6d setup
ospf6d_setup() {
  echo -e "\nConfiguring Ospf6"
  # Initially create the conf with just lo iface
  # and general options
  echo -e "! -*- ospf6 -*-
!
hostname $MYNAME
password $ROUTERPWD
log file /var/log/quagga/ospf6d.log\n
interface lo
!ipv6 ospf6 cost ${LOOPBACK[1]}
ipv6 ospf6 hello-interval 600\n" > /etc/quagga/ospf6d.conf

  # Iterate over the interfaces and
  # add them to the config file
  for i in ${TAP[@]}; do
    if [ "$TUNNELING" = "OpenVPN" ]; then
      eval quaggaospfcost=\${${i}[4]}
      eval quaggahellointerval=\${${i}[5]}
    elif [ "$TUNNELING" = "VXLAN" ]; then
      # Create config files for the taps and setup the tunnels
      eval quaggaospfcost=\${${i}[3]}
      eval quaggahellointerval=\${${i}[4]}
    fi
    echo -e "interface $i
ipv6 ospf6 cost $quaggaospfcost
ipv6 ospf6 hello-interval $quaggahellointerval\n" >> /etc/quagga/ospf6d.conf
  done

  # Enable ospf6 and other general config
  echo -e "router ospf6" >> /etc/quagga/ospf6d.conf
  echo -e "router-id $ROUTERID" >> /etc/quagga/ospf6d.conf
  echo -e "redistribute static" >> /etc/quagga/ospf6d.conf

  # Add the net to the config
#  for i in ${OSPFNET[@]}; do
#    eval quaggaannouncednet=\${${i}[0]}
#    eval quaggarouterarea=\${${i}[1]}
#    echo "area $quaggarouterarea range $quaggaannouncednet" >> /etc/quagga/ospf6d.conf
#  done
  echo -e "area 0.0.0.0 range $RANGE_FOR_AREA_0" >> /etc/quagga/ospf6d.conf

  # Define the area of the interfaces
  echo -e "interface lo area 0.0.0.0" >> /etc/quagga/ospf6d.conf
  for i in ${TAP[@]}; do
     echo -e "interface $i area 0.0.0.0" >> /etc/quagga/ospf6d.conf
  done
}

# Create zebra setup
zebra_setup() {
  echo -e "\nConfiguring Zebra"
  # Initially create the conf with just lo iface
  # and general options
  echo -e "
! -*- zebra -*-
log file /var/log/quagga/zebra.log\n
hostname $MYNAME
password ${ROUTERPWD}
enable password ${ROUTERPWD}

interface lo
link-detect
ipv6 nd ra-interval 10
ipv6 address ${LOOPBACK[0]}
ipv6 nd prefix ${LOOPBACK[0]}
" > /etc/quagga/zebra.conf

  # Iterate over the interfaces and
  # add them to the config file
  for i in ${TAP[@]}; do
    if [ "$TUNNELING" = "OpenVPN" ]; then
      eval addr=\${${i}[3]}
      eval prefix=\${!$i[6]}
    elif [ "$TUNNELING" = "VXLAN" ]; then
      # Create config files for the taps and setup the tunnels
      eval addr=\${${i}[2]}
      eval prefix=\${!$i[5]}
    fi
    echo -e "
interface ${i}
link-detect
no ipv6 nd suppress-ra
ipv6 nd ra-interval 10
ipv6 address $addr
ipv6 nd prefix $prefix" >> /etc/quagga/zebra.conf
  done
  for i in ${STATIC_ROUTES[@]}; do
  echo -e "
ipv6 route $i ::1" >> /etc/quagga/zebra.conf
  done

}

# Create vxlan setup
vxlan_setup() {
  echo -e "\nConfiguring VXLAN"
  # configuring tunnel interfaces
  j=0
  for i in ${TAP[@]}; do
    eval vni=\${${i}[0]}
    eval ELEMENT=\${${i}[1]}
    # Update properly endpoints array
    if [ $(echo ${ENDIPS[@]} | grep -o $ELEMENT | wc -w) -eq 0 ]; then
      ENDIPS[${#ENDIPS[@]}]=$ELEMENT
    fi
    eval remoteaddr=\${${ENDIPS[j]}[0]}
    eval interface=\${${ENDIPS[j]}[1]}
    j=$((j+1))
    # Create the tunnel
    echoeval ip link add name $i type vxlan id $vni dev $interface remote $remoteaddr dstport 4789
  done

  # Bring up the tap interfaces
  for i in ${TAP[@]}; do
    echoeval ip link set ${i} up
  done

}

# Create openvpn config
openvpn_setup() {
  echo -e "\nConfiguring OpenVPN"
  # writing *.conf OpenVPN files in /etc/openvpn
  for i in ${TAP[@]}; do
    eval localport=\${${i}[0]}
    eval remoteport=\${${i}[1]}
    eval remoteaddr=\${!$i[2]}
    echo "dev ${i}
mode p2p
port $localport
remote $remoteaddr $remoteport
daemon" > /etc/openvpn/$i.conf
  done

  # Start the daemon and bring up the tap interfaces
  for i in ${TAP[@]}; do
    openvpn /etc/openvpn/$i.conf
    ip link set ${i} up
  done
}

# Setup properly the interfaces on the machine
# THIS NOT CALLED NOW, BECAUSE THERE IS NO NEED TO SETUP STATIC ROUTES
# TO FORCE THE EXIT INTERFACE
setup_interfaces () {
  # Tunneling is not used, just bring up the interfaces
  for i in ${INTERFACES[@]}; do
      ip link set $i up
    done
  # When there is tunneling we need to set other things
  if ! [ "$TUNNELING" = "NO" ];then
    # Since we are using tunneling, we need to
    # set static routes for the remotes
    declare -a ENDIPS
    # Iterate over the tunnel interfaces
    for i in ${TAP[@]}; do
      # If we are using OpenVPN, we have an element more
      if [ "$TUNNELING" = "OpenVPN" ]; then
        eval ELEMENT=\${${i}[2]}
      else
        eval ELEMENT=\${${i}[1]}
      fi
      # Update properly endpoints array
      if [ $(echo ${ENDIPS[@]} | grep -o $ELEMENT | wc -w) -eq 0 ];then
        ENDIPS[${#ENDIPS[@]}]=$ELEMENT
      fi
    done

    # Let's finally setup the static routes
    for (( i=0; i<${#ENDIPS[@]}; i++ )); do
      eval remoteaddr=\${${ENDIPS[$i]}[0]}
      eval interface=\${${ENDIPS[$i]}[1]}
      ip r a $remoteaddr dev $interface
    done
  fi
}

# Make sure only root can run our script
echo -e "\nChecking permission"
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as root\n" 1>&2
   exit 1
fi
echo -e "Ok!"

# Get ip address of $INTERF_NAME
#myip=$(ip a show dev $INTERF_NAME | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# Let's setup the interfaces, the configuration depends on
# the tunneling has been chosen for this node
#echo -e "Setting up interfaces"
#setup_interfaces

# Stopping avahi-daemon
if [ $(ps aux | grep avahi-daemon | wc -l) -gt 1 ]; then
  /etc/init.d/avahi-daemon stop
fi

# Start OpenVPN tunnels
if [ "$TUNNELING" = "OpenVPN" ]; then
  # Create config files for the taps and setup the tunnels
  openvpn_setup
elif [ "$TUNNELING" = "VXLAN" ]; then
  # Create config files for the taps and setup the tunnels
  vxlan_setup
fi

# Let's configure routing daemon
echo -e "\nConfiguring Quagga"
zebra_setup
ospf6d_setup
quagga_setup

# Configure IPv6
ipv6_setup

# Configure VNFs and terminals
vnfs_terms_setup


echo -e "\nSRv6 Router node config ended succesfully. Enjoy!\n"

EXIT_SUCCESS=0
exit $EXIT_SUCCESS
