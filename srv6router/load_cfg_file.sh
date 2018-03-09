#!/bin/bash

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
