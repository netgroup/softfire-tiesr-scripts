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
# The script installs SRv6Router node packages on Linux Ubuntu 17.10
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

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
