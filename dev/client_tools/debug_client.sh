#!/bin/bash

tmpfolder="/tmp"
identityfile="/root/.ssh/id_rsa"

ip_addresses_list=$(echo "select distinct name from glpi_ipaddresses where version=4;" | mysql -s glpi)

ip_address_error=''

for ip_address in ${ip_addresses_list}; do
	echo "Contacting ${ip_address}"
	ssh -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
	pulse@${ip_address} hostname
	if [ $? -eq 0 ]; then
        mkdir -p ${tmpfolder}/${ip_address}/
		echo "Downloading xmpp-agent.log"
		scp -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\var\\log\\xmpp-agent.log\"" ${tmpfolder}/${ip_address}/
		echo ""
		echo "Downloading config files"
		scp -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\etc\\agentconf.ini\"" ${tmpfolder}/${ip_address}/
        scp -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\etc\\manage_scheduler.ini\"" ${tmpfolder}/${ip_address}/
        scp -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\etc\\cluster.ini\"" ${tmpfolder}/${ip_address}/
        scp -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address}:"\"c:\\Program Files\\Pulse\\etc\\inventory.ini\"" ${tmpfolder}/${ip_address}/
		echo ""
		echo "Getting list of processes"
        process_list=$(ssh -o IdentityFile=${identityfile} -o StrictHostKeyChecking=no -o Batchmode=yes -o PasswordAuthentication=no -o ServerAliveInterval=10 -o CheckHostIP=no -o ConnectTimeout=10 \
		pulse@${ip_address} wmic process list brief)
        echo ${process_list} > ${tmpfolder}/${ip_address}/process_list.txt
        echo ""
		echo "***********************************"
		echo ""
    else
        ip_address_error+=" ${ip_address}"
	fi
done

if [ "${ip_address_error}" != '' ]; then
    echo "############################################################"
    echo "The following machines could not be contacted: ${ip_address_error}"
    echo "############################################################"
fi
