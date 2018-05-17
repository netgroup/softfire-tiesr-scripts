# SoftFIRE TIESR Scripts #

This project is a collection of scripts to run SRv6 based experiments over SoftFIRE testbed

### Structure ###

The project is divided in several subfolders, one folder for each type of supported node

	> softfire-tiesr-scripts
		> output-logs
		> srv6router

output-logs contains the log of the executions

srv6router contains the scripts to setup and configure a SRv6 Router

	> softfire-tiesr-scripts
		> srv6router
			> cfg
			> setup.sh
			> config.sh
			> clean.sh

cfg folder contains examples of configuration files which can be run over a SoftFire testbed. Hereafter a configuration example:

	#!/bin/bash
	TESTBED=SOFTFIRE
	TUNNELING=VXLAN
	ROUTERPWD=srv6
	ROUTERID=0.0.0.1

	declare -a LOOPBACK=(fdff::1/128 1 2 LBN)
	declare -a TAP=(tap1 tap2)
	declare -a tap1=(1 endip1 fdf0::1/64 5 1 NET1)
	declare -a tap2=(2 endip2 fdf0:0:0:1::1/64 5 1 NET2)
	declare -a endip1=(192.168.213.9 ens3)
	declare -a endip2=(172.20.18.183 ens3)

	declare -a OSPFNET=(VNE1 LBN NET1 NET2)
	declare -a VNE1=(fd01:f1::/32 0.0.0.0)
	declare -a LBN=(fdff::1/128 0.0.0.0)
	declare -a NET1=(fdf0::/64 0.0.0.0)
	declare -a NET2=(fdf0:0:0:1::/64 0.0.0.0)

	declare -a VNF=(vnf1)
	declare -a vnf1=(lxd vnf1 vnf1_DEV)
	declare -a vnf1_DEV=(vnf1_DEV1)
	declare -a vnf1_DEV1=(L3 fd01:f1::fe 32 fd01:f1::1 eth0 br1)

	declare -a STATIC_ROUTES=(fd01::/16)


setup.sh installs all the necessary dependencies to run a SRv6 enable Router

config.sh downloads the configuration file (if not present) for the management server and setup properly the node

clean.sh cleans the environment reverting back all the changes introduced by config
