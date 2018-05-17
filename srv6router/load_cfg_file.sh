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
# The script loads configuration file
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

# First step is the download of the right configuration file
CFG_FOLDER=cfg

echo -e "\nLooking for a valid configuration file $CFG_FOLDER/$MYNAME.cfg"
# if $MYNAME.cfg does not exist we try to download from the server

if [ -f $CFG_FOLDER/$MYNAME.cfg ]; then
  # If cfg file is present in current folder, use it
  echo -e "File found in $(pwd)/$CFG_FOLDER/"
  echo -e "Using local configuration file $CFG_FOLDER/$MYNAME.cfg"
  source $CFG_FOLDER/$MYNAME.cfg
else
  # If cfg file is not present in current folder, we download it
  echo -e "Local configuration file not found in $(pwd)"
  echo -e "Downloading from $MGMT"
  wget -O $CFG_FOLDER/$MYNAME.cfg http://$MGMT:4000/static/cfg/$MYNAME.cfg
  if [ -f $CFG_FOLDER/$MYNAME.cfg ]; then
    source $CFG_FOLDER/$MYNAME.cfg
  else
    echo -e "Update Failed...Check Server $MGMT\n"
    exit 1
  fi
fi
echo -e "Ok!\n"
