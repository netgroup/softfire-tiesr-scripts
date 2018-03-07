#!/bin/bash
# The script installs SRv6Router node packages on Linux Ubuntu 17.10

MY_HOST_ID="ADS1"
MGMT=172.17.0.1

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node setup                 ##"
echo "##                                                        ##"
echo "##    The installation process can last many minutes.     ##"
echo "##   Plase wait and do not interrupt the setup process.   ##"
echo "############################################################"

echo -e 'MYNAME="$MY_HOST_ID"' > /etc/myhostid

