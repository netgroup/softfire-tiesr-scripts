# SoftFIRE TIESR Scripts #

This project is a collection of scripts to run SRv6 based experiments over SoftFIRE testbed

### Structure ###

The project is divided in several subfolders, one folder for each type of supported node

	> softfire-tiesr-scripts
		> srv6router

srv6router contains the scripts to setup and configure a SRv6 Router

	> softfire-tiesr-scripts
		> srv6router
			> setup.sh
			> config.sh
			> clean.sh

setup.sh installs all the necessary dependencies to run a SRv6 enable Router

config.sh downloads the configuration file (if not present) for the management server and setup properly the ndoe

clean.sh cleans the environment reverting back all the changes introduced by config

The following is an example of configuration files for two nodes using OpenVPN as tunneling mechanism and connected by a point-to-point link

	#!/bin/bash
	TESTBED=SOFTFIRE
	TUNNELING=OpenVPN
	HOST=srv61
	ROUTERPWD=srv6
	ROUTERID=172.16.0.1
	declare -a MGMTNET=(172.17.0.0 255.255.0.0 172.17.0.1 eth0)
	declare -a LOOPBACK=(2000::AC10:0001/128 1 1 NET1)
	declare -a INTERFACES=(eth1)
	declare -a eth1=(172.18.0.2 255.255.0.0)
	declare -a TAP=(tap1)
	declare -a tap1=(1191 1191 endip1 2001:0:0:0::1/64 1 1 NET2)
	declare -a endip1=(172.18.0.3 eth1)
	declare -a OSPFNET=(NET1 NET2 NET3)
	declare -a NET1=(2000::AC10:0001/128 0.0.0.0)
	declare -a NET2=(2001:0:0:0::/64 0.0.0.0)
	declare -a NET3=(2002:0:0:1::/64)

	#!/bin/bash
	TESTBED=SOFTFIRE
	TUNNELING=OpenVPN
	HOST=srv62
	ROUTERPWD=srv6
	ROUTERID=172.16.0.2
	declare -a MGMTNET=(172.17.0.0 255.255.0.0 172.17.0.1 eth0)
	declare -a LOOPBACK=(2000::AC10:0002/128 1 1 NET1)
	declare -a INTERFACES=(eth1)
	declare -a eth1=(172.18.0.3 255.255.0.0)
	declare -a TAP=(tap1)
	declare -a tap1=(1191 1191 endip1 2001:0:0:0::2/64 1 1 NET2)
	declare -a endip1=(172.18.0.2 eth1)
	declare -a OSPFNET=(NET1 NET2)
	declare -a NET1=(2000::AC10:0002/128 0.0.0.0)
	declare -a NET2=(2001:0:0:0::/64 0.0.0.0)

The following is an example of configuration files for two nodes using VXLAN as tunneling mechanism and connected by a point-to-point link

	#!/bin/bash
	TESTBED=SOFTFIRE
	TUNNELING=VXLAN
	HOST=srv61
	ROUTERPWD=srv6
	ROUTERID=172.16.0.1
	declare -a MGMTNET=(172.17.0.0 255.255.0.0 172.17.0.1 eth0)
	declare -a LOOPBACK=(2000::AC10:0001/128 1 1 NET1)
	declare -a INTERFACES=(eth1)
	declare -a eth1=(172.18.0.2 255.255.0.0)
	declare -a TAP=(tap1)
	declare -a tap1=(1 endip1 2001:0:0:0::1/64 1 1 NET2)
	declare -a endip1=(172.18.0.3 eth1)
	declare -a OSPFNET=(NET1 NET2 NET3)
	declare -a NET1=(2000::AC10:0001/128 0.0.0.0)
	declare -a NET2=(2001:0:0:0::/64 0.0.0.0)
	declare -a NET3=(2002:0:0:1::/64)

	#!/bin/bash
	TESTBED=SOFTFIRE
	TUNNELING=VXLAN
	HOST=srv62
	ROUTERPWD=srv6
	ROUTERID=172.16.0.2
	declare -a MGMTNET=(172.17.0.0 255.255.0.0 172.17.0.1 eth0)
	declare -a LOOPBACK=(2000::AC10:0002/128 1 1 NET1)
	declare -a INTERFACES=(eth1)
	declare -a eth1=(172.18.0.3 255.255.0.0)
	declare -a TAP=(tap1)
	declare -a tap1=(1 endip1 2001:0:0:0::2/64 1 1 NET2)
	declare -a endip1=(172.18.0.2 eth1)
	declare -a OSPFNET=(NET1 NET2 NET3)
	declare -a NET1=(2000::AC10:0002/128 0.0.0.0)
	declare -a NET2=(2001:0:0:0::/64 0.0.0.0)



