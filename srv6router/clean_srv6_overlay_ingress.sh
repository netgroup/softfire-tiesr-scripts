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
# The script cleans the configuration of SRv6 ingress node
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it>

# Clean SRv6 policy for traffic term1 -> term3
echo -e "Deleting SRv6 TE policy for traffic term1 -> term3 ......"
sudo ip -6 route del fd04:02::/32 dev tap1 encap seg6 mode encap segs fdff::1,fdff::4
echo -e "...... OK! \n"

# Clean SRv6 policy for traffic term1 -> term4
echo -e "Deleting SRv6 TE+SFC policy for traffic term1 -> term4 ......"
sudo ip -6 route del fd04:03::/32 dev tap1 encap seg6 mode encap segs fdff::1,fd01:f1::1,fdff::4 
echo -e "...... OK! \n"
