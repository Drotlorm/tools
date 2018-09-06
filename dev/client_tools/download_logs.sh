#!/bin/bash

ip_addresses_list=$(echo "select distinct name from glpi_ipaddresses where version=4;" | mysql -s glpi)

ip_address_error=''
for ip_address in ${ip_addresses_list}; do
	echo "Contacting ${ip_address}"
	ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
	pulse@${ip_address} hostname
	if [ $? -eq 0 ]; then
		echo "Downloading xmpp-agent.log"
		mkdir -p /tmp/xmpp-logs/${ip_address}/
		scp -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\var\\log\\xmpp-agent.log\"" /tmp/xmpp-logs/${ip_address}/
		echo ""
		echo "***********************************"
		echo ""
    else
        ip_address_error+=" ${ip_address}"
	fi
done

if [[ ${ip_address_error} != '' ]]; then
    echo "############################################################"
    echo "The following machines could not be contacted: ${ip_address_error}"
    echo "############################################################"
fi
