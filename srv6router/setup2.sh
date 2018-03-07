#!/bin/bash
# This script installs SRv6Router node packages on Linux Ubuntu 17.10

MY_HOST_ID="ADS1"
MGMT=172.17.0.1

echo -e "MYNAME=\c" > /etc/myhostid
echo -e "$MY_HOST_ID" >> /etc/myhostid

if [ -f $MY_HOST_ID.setup ]; then
  echo -e "Using local file $MY_HOST_ID.setup found in $(pwd)"
  source $MY_HOST_ID.setup
else
  echo -e "Local setup file not found in $(pwd). Download from $MGMT"
  wget $MGMT/$MY_HOST_ID.setup
  if [ -f $MY_HOST_ID.setup ]; then
    source $MY_HOST_ID.setup
  else
    echo -e "Update Failed...Check Server $MGMT\n"
    exit 1
  fi
fi
echo -e "Ok!\n"
