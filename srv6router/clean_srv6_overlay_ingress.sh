#!/bin/bash
# The script cleans the configuration of SRv6 ingress node

# Clean SRv6 policy for traffic term1 -> term3
echo -e "Deleting SRv6 TE policy for traffic term1 -> term3 ......"
sudo ip -6 route del fd04:02::/32 dev tap1 encap seg6 mode encap segs fdff::1,fdff::4
echo -e "...... OK! \n"

# Clean SRv6 policy for traffic term1 -> term4
echo -e "Deleting SRv6 TE+SFC policy for traffic term1 -> term4 ......"
sudo ip -6 route del fd04:03::/32 dev tap1 encap seg6 mode encap segs fdff::1,fd01:f1::1,fdff::4 
echo -e "...... OK! \n"
