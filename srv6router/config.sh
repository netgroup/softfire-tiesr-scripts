#!/bin/bash
# The script configures SRv6Router node

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node setup                 ##"
echo "##                                                        ##"
echo "##    The installation process can last many minutes.     ##"
echo "##   Plase wait and do not interrupt the setup process.   ##"
echo "############################################################"

# Address of the management server
MGMT=172.17.0.1

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
script-security 3 system
daemon" > /etc/openvpn/$i.conf
  done

  # Start the daemon and bring up the tap interfaces
  for i in ${TAP[@]}; do
    openvpn /etc/openvpn/$i.conf
    ip link set ${i} up
  done
}

# Setup properly the interfaces on the machine
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

# Get ip address of eth0
myip=$(ip a show dev eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
# First step is the download of the right configuration file
echo -e "\nLooking for a valid configuration file $myip.cfg"
# if myip.cfg does not exist we try to download from the server
if [ -f $myip.cfg ]; then
  # If cfg file is present in current folder, use it
  echo -e "File found in $(pwd)"
  echo -e "Using local configuration file $myip.cfg"
  source $myip.cfg
else
  # If cfg file is not present in current folder, we download it
  echo -e "Local configuration file not found in $(pwd)"
  echo -e "Downloading from $MGMT"
  wget $MGMT/$myip.cfg
  if [ -f $myip.cfg ]; then
    source $myip.cfg
  else
    echo -e "Update Failed...Check Server $MGMT\n"
    exit 1
  fi
fi
echo -e "Ok!\n"

# Let's setup the interfaces, the configuration depends on
# the tunneling has been chosen for this node
echo -e "Setting up interfaces"
setup_interfaces

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

echo -e "\nSRv6 Router node config ended succesfully. Enjoy!\n"

EXIT_SUCCESS=0
exit $EXIT_SUCCESS
