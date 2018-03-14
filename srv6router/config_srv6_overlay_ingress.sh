#!/bin/bash
# The script configures the Ingress node of the SRv6 domain 

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
