#!/bin/bash

vnfs_terms_setup () {
  echo "VNFs and TERMs SETUP"
  for i in ${VNF[@]}; do

    eval TYPE_VNF_TERM=\${${i}[0]}
    #echo $TYPE_VNF_TERM
    eval VNF_NAME=\${${i}[1]}
    #echo $VNF_NAME
    eval VNF_DEV=\${${i}[2]}
    #echo $VNF_DEV

    tmp=$VNF_DEV[@]
    DEVARRAY=( "${!tmp}" )
    #echo ${DEVARRAY[@]}

    for j in ${DEVARRAY[@]}; do
      eval LAYER=\${$DEVARRAY[0]}
      #echo $LAYER
      eval IP_GW=\${$DEVARRAY[1]}
      #echo $IP_GW
      eval NETMASK=\${$DEVARRAY[2]}
      #echo $NETMASK
      eval IP_VNF=\${$DEVARRAY[3]}
      #echo $IP_VNF
      eval DEV_NAME=\${$DEVARRAY[4]}
      #echo $DEV_NAME
      eval BR_NAME=\${$DEVARRAY[5]}
      #echo $BR_NAME

      if [ "$TYPE_VNF_TERM" = "lxd" ]; then
        lxd_container $VNF_NAME $IP_GW $NETMASK $IP_VNF $DEV_NAME $BR_NAME
      elif [ "$TYPE_VNF_TERM" = "netns" ]; then
        netns $VNF_NAME $IP_GW $NETMASK $IP_VNF $DEV_NAME $BR_NAME
      fi

    done

  done
}