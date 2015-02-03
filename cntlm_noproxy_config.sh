#!/bin/bash

# script for automatic reconfiguration of CNTLM's NoProxy setting
#
# changes NoProxy setting according to assigned IP address, for example
# to skip corporate proxy when not in corporate network and to use the proxy
# with desired exceptions when in corporate network
#
# usage:
# 1. make sure $CNTLM_CONF points to your CNTLM config file
# 2. define $COMPANY_SUBNET to match IP address in your corporate network
# 3. customize $NO_PROXY_CORPORATE for your corporate network
# 4. place this script in /etc/NetworkManager/dispatcher.d and configure order
# 5. make script executable and set ownership to root:root
#
# this script logs its config changes to syslog
#
# further references:
# http://cntlm.sourceforge.net/
# http://linux.die.net/man/8/networkmanager

readonly CNTLM_CONF="/etc/cntlm.conf"
readonly COMPANY_SUBNET="10.0.0"
readonly NO_PROXY_CORPORATE="localhost, 127.0.0.*, 10.*, 192.168.*"
readonly NO_PROXY_DIRECT="*"

if [ ! -f $CNTLM_CONF ]; then
	logger "$(basename "$0") - $CNTLM_CONF does not exist"
	exit 1
fi

case "$2" in
	up|vpn-up)
		hostname -I | grep -q $COMPANY_SUBNET

		if [ $? -eq 0 ]; then
			logger "$(basename "$0") - set NoProxy for corporate net"
			NO_PROXY=$NO_PROXY_CORPORATE
		else
			logger "$(basename "$0") - set NoProxy for direct net"
			NO_PROXY=$NO_PROXY_DIRECT
		fi

		sed "s/^NoProxy.*$/NoProxy\t\t$NO_PROXY/g" -i $CNTLM_CONF
		invoke-rc.d cntlm restart
		;;
esac
