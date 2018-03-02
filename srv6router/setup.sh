#!/bin/bash
# The script installs SRv6Router node packages on Linux Ubuntu 17.10

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node setup                 ##"
echo "##                                                        ##"
echo "##    The installation process can last many minutes.     ##"
echo "##   Plase wait and do not interrupt the setup process.   ##"
echo "############################################################"

install_quagga(){
  apt install -y gawk
  apt install -y texinfo
  apt install -y quagga
}

install_iproute2(){
  wget https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.15.0.tar.gz
  tar -zxvf iproute2-4.15.0.tar.gz
  cd iproute2-4.15.0
  make
  make install
  cd ../
  rm -r iproute2-4.15.0
  rm iproute2-4.15.0.tar.gz
}

# Make sure only root can run our script
echo -e "\nChecking permission"
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as root\n" 1>&2
   exit 1
fi
echo -e "Ok!"

# Verify the setup has not been already performed
echo -e "\nChecking setup already performed"
if [ -f /etc/setup ]; then
  echo -e "Setup already executed...exit\n"
  exit 0
fi
echo -e "Ok!"

# Trasform in a magic number and compare against 410
echo -e "\nChecking Kernel version"
if [ $(uname -r | awk -F. '{print $1$2}') -lt 410 ]; then
  echo -e "SRv6 not supported in this kernel...exit\n"
  exit 0
fi
echo -e "Ok!"

echo -e "\nInstalling dependencies"
# Let's install all the dependencies
apt update

echo -e "\nInstalling OpenVPN"
# We need openvpn for tunnels
apt-get install -y openvpn

echo -e "\nInstalling VLAN packages"
# Vlan can be always useful
apt install -y vlan

echo -e "\nInstalling make"
apt install -y make

echo -e "\nInstalling pkg-Config"
apt install -y pkg-config

echo -e "\nInstalling bison"
apt install -y bison

echo -e "\nInstalling flex"
apt install -y flex

echo -e "\nInstalling Quagga router services"
# Quagga dependencies are: gawk, textinfo
install_quagga

echo -e "\nInstalling iproute2"
install_iproute2

echo -e "Ok!"

# Enable IPv6 forwarding and Seg6 forwarding
echo -e "\nEnabling IPv6 forwarding"
sysctl -w net.ipv6.conf.all.forwarding=1

echo -e "\nEnabling Seg6 forwarding"
sysctl -w net.ipv6.conf.all.seg6_enabled=1

# Create setup file
touch /etc/setup

echo -e "\nSRv6 Router node setup ended succesfully. Enjoy!\n"

EXIT_SUCCESS=0
exit $EXIT_SUCCESS
