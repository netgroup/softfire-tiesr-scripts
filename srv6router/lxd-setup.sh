#!/bin/bash

echoeval () {
		echo "$@"
		eval "$@"
}

cat <<EOF | lxd init --preseed
config:
EOF

CONTAINER=vnf1
echoeval lxc launch ubuntu:17.10 $CONTAINER
echoeval lxc file push setup-snort.sh $CONTAINER/root/
echoeval lxc network create $CONTAINER-br
echoeval lxc network attach $CONTAINER-br $CONTAINER eth0
echoeval lxc exec $CONTAINER -- ip link set dev eth0 up
echoeval lxc exec $CONTAINER -- sleep 10
echoeval lxc exec $CONTAINER -- ping -c 3 www.google.com
echoeval lxc exec $CONTAINER -- chmod +x setup-snort.sh
echoeval lxc exec $CONTAINER -- chmod +x aux-setup-snort.sh
echoeval lxc exec $CONTAINER -- ./setup-snort.sh $CONTAINER
echoeval lxc exec $CONTAINER -- ls -l /root
echoeval lxc file pull $CONTAINER/root/$CONTAINER-setup-snort.log .
#cat $CONTAINER-setup-snort.log



