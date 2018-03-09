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

#INTERF_NAME="eth0"
# Address of the management server
MGMT=172.17.0.1
QUAGGA_PATH="/usr/sbin"
#QUAGGA_PATH="/usr/lib/quagga"

# Setup properly IPv6
ipv6_setup() {
  echo -e "\nConfiguring IPv6"
  # Enable IPv6 forwarding
  sysctl -w net.ipv6.conf.all.forwarding=1
  sysctl -w net.ipv6.conf.all.seg6_enabled=1
  for i in ${TAP[@]}; do
    # Enable IPv6 forwarding
    sysctl -w net.ipv6.conf.$i.forwarding=1
    # Enable Seg6
    sysctl -w net.ipv6.conf.$i.seg6_enabled=1
  done
}

# $1=vnf1 $2=fd04:f1::fe $3=32 $4=fd04:f1::1 $5=eth0
lxd_container () {

VNF_NAME=$1
GW_IP=$1
NETMASK=$3
VNF_IP=$4
DEV_NAME=$5

BR_NAME=br$VNF_NAME

#lxc network detach brvnf vnf1
lxc network detach $BR_NAME $VNF_NAME
#lxc network delete brvnf1 
lxc network delete $BR_NAME 
#lxc network create brvnf1 ipv6.address=fd04:f1::fe/32 ipv4.address=none 
lxc network create $BR_NAME ipv6.address=$GW_IP/$NETMASK ipv4.address=none 
#lxc network attach brvnf1 vnf1 eth0
lxc network attach $BR_NAME $VNF_NAME $DEV_NAME
#lxc exec vnf1 -- ip -6 a a  fd04:f1::1/32 dev eth0
lxc exec $VNF_NAME -- ip -6 a a  $VNF_IP/$NETMASK dev $DEV_NAME
#lxc exec vnf1 -- ip -6 r a default via fd04:f1::fe dev eth0
lxc exec $VNF_NAME -- ip -6 r a default via $GW_IP dev $DEV_NAME
#lxc exec vnf1 -- ip link set dev eth0 up
lxc exec $VNF_NAME -- ip link set dev $DEV_NAME up
#sudo ip link set dev vnfbr1 up
sudo ip link set dev $BR_NAME up
}


#declare -a VNF1=(lxd vnf1 VNF1_DEV)
#declare -a VNF1_DEV=(VNF1_DEV1 VNF2_DEV2)
#declare -a VNF1_DEV1=(L3 fd01:f1::fe 32 fd01:f1::1 $VNF_IF)
#declare -a VNF1_DEV2=(L3 fd01:f8::fe 32 fd01:f8::1 eth1)

#declare -a VNF2=(lxd vnf2 VNF2_DEV)
#declare -a VNF2_DEV=(VNF2_DEV1)
#declare -a VNF2_DEV1=(L3 fd01:f2::fe 32 fd01:f2::1 $VNF_IF)

vnfs_terms_setup () {
  echo "VNFs and TERMs SETUP"
  for i in ${VNF[@]}; do

    eval TYPE_VNF_TERM=\${${i}[0]}
    echo $TYPE_VNF_TERM
    eval VNF_NAME=\${${i}[1]}
    echo $VNF_NAME
    eval VNF_DEV=\${${i}[2]}
    echo $VNF_DEV
    eval MY_ARRAY=\${!$i[2]}
    echo $MY_ARRAY

    tmp=$VNF_DEV[@]
    NEWARRAY=( "${!tmp}" )
    echo ${NEWARRAY[@]}

    eval LAYER=\${$MY_ARRAY[0]}
    echo $LAYER
    eval IP_GW=\${$MY_ARRAY[1]}
    echo $IP_GW


    #eval remoteport=\${${i}[1]}
    #eval remoteaddr=\${!$i[2]}
  done
}


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
ipv6 ospf6 cost ${LOOPBACK[1]}
ipv6 ospf6 hello-interval ${LOOPBACK[2]}\n" > /etc/quagga/ospf6d.conf

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
  echo -e "redistribute kernel\n" >> /etc/quagga/ospf6d.conf

  # Add the net to the config
  for i in ${OSPFNET[@]}; do
    eval quaggaannouncednet=\${${i}[0]}
    eval quaggarouterarea=\${${i}[1]}
    echo "area $quaggarouterarea range $quaggaannouncednet" >> /etc/quagga/ospf6d.conf
  done
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
ipv6 address $LOOPBACK
ipv6 nd prefix $LOOPBACK" > /etc/quagga/zebra.conf

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
    ip link add name $i type vxlan id $vni dev $interface remote $remoteaddr dstport 4789
  done

  # Bring up the tap interfaces
  for i in ${TAP[@]}; do
    ip link set ${i} up
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

# First step is the download of the right configuration file
echo -e "\nLooking for a valid configuration file $MYNAME.cfg"
# if $MYNAME.cfg does not exist we try to download from the server

if [ -f $MYNAME.cfg ]; then
  # If cfg file is present in current folder, use it
  echo -e "File found in $(pwd)"
  echo -e "Using local configuration file $MYNAME.cfg"
  source $MYNAME.cfg
else
  # If cfg file is not present in current folder, we download it
  echo -e "Local configuration file not found in $(pwd)"
  echo -e "Downloading from $MGMT"
  wget $MGMT/$MYNAME.cfg
  if [ -f $MYNAME.cfg ]; then
    source $MYNAME.cfg
  else
    echo -e "Update Failed...Check Server $MGMT\n"
    exit 1
  fi
fi
echo -e "Ok!\n"

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
