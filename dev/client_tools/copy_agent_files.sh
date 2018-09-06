#!/bin/bash

ip_addresses_list=$(echo "select distinct name from glpi_ipaddresses where version=4;" | mysql -s glpi)

ip_address_error=''
for ip_address in ${ip_addresses_list}; do
	echo "Contacting ${ip_address}"
	ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
	pulse@${ip_address} hostname
	if [ $? -eq 0 ]; then
		echo "Killing Pulse Agent"
		ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address} schtasks /End /TN "\"Pulse Agent\""
		ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address} taskkill /F /IM python.exe
		sleep 3
		echo ""
		echo "Copying Agent files"
		scp -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		/tmp/pulse-xmpp-agent-1.9.6/pulse_xmpp_agent/*.py pulse@${ip_address}:"\"c:\\Python27\\Lib\\site-packages\\pulse_xmpp_agent\""
		scp -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		/tmp/pulse-xmpp-agent-1.9.6/pulse_xmpp_agent/lib/*.py pulse@${ip_address}:"\"c:\\Python27\\Lib\\site-packages\\pulse_xmpp_agent\\lib\""
        scp -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		/tmp/pulse-agent-plugins-1.8/pulse_agent_plugins/common/*.py pulse@${ip_address}:"\"c:\\Python27\\Lib\\site-packages\\pulse_xmpp_agent\\pluginsmachine\""
        scp -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		/tmp/pulse-agent-plugins-1.8/pulse_agent_plugins/machine/*.py pulse@${ip_address}:"\"c:\\Python27\\Lib\\site-packages\\pulse_xmpp_agent\\pluginsmachine\""
		echo "Restarting Pulse Agent"
		ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address} schtasks /Run /TN "\"Pulse Agent\""
		sleep 2
		ssh -o IdentityFile=/root/.ssh/id_rsa -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address} schtasks /Query /TN "\"Pulse Agent\""
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
