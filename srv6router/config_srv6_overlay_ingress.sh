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
# The script configures the Ingress node of the SRv6 domain
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

# Configure SRv6 policy for traffic term1 -> term2
# No SRv6 policy needed. Routing daemon does the job. 

# Configure SRv6 policy for traffic term1 -> term3
echo -e "Configuring SRv6 TE policy for traffic term1 -> term3 ......"
echo -e "term1 -> ADS1 -> Surrey2 -> term3 ......"
sudo ip -6 route add fd04:02::/32 dev tap1 encap seg6 mode encap segs fdff::1,fdff::4
echo -e "...... OK! \n"

# Configure SRv6 policy for traffic term1 -> term4
echo -e "Configuring SRv6 TE+SFC policy for traffic term1 -> term4 ......"
echo -e "term1 -> ADS1 -> VNF1 -> Surrey2 -> term3 ......"
sudo ip -6 route add fd04:03::/32 dev tap1 encap seg6 mode encap segs fdff::1,fd01:f1::1,fdff::4 
echo -e "...... OK! \n"
