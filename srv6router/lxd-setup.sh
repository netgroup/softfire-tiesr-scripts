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
# The script setups a lxd container
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

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



