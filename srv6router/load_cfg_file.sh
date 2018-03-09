#!/bin/bash

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
  wget -O $CFG_FOLDER/$MYNAME.cfg $MGMT/$MYNAME.cfg 
  if [ -f $CFG_FOLDER/$MYNAME.cfg ]; then
    source $CFG_FOLDER/$MYNAME.cfg
  else
    echo -e "Update Failed...Check Server $MGMT\n"
    exit 1
  fi
fi
echo -e "Ok!\n"
