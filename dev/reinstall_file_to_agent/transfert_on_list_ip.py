#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ce script reinstalle un fichier sur l'agent, et redémarre l'agent windows

"""
la variable  namefiletotransfert contient le path du fichier a reinstallé.
la variable  transfertou contient le path ou le fichier sera installer sur la machine distante.


Le script utilise scp pour envoyer le fichier a distance.
et utilise ssh pour passer les commandes a la machine distante. pour redémarer l'agent apres la modification. 

Il ne peut atteindre que les machine allumé. machine ok
les machines éteintes machine ko.

le script present travaille avec un fichier possédant une liste de ip de machine en entree

il est généré 2 fichiers en sortie.
le fichier des ip    ok
et le fichier des ip ko.

permettant de reproduire le script sur les machines ko uniquement.

Methode pour récupérer les ip des machines en liste.
# fichier ip.txt result de SELECT distinct name FROM glpi.glpi_ipaddresses where name like "10.%";
# cat  `ls /var/log/mmc/mmc-agent*` | grep xmppip | grep "10.1" | grep -v DEBUG | awk '{print $7}' | sort | uniq > /root/ipadress.txt
"""

import subprocess
import threading
import sys
import os
import logging
import re
import sys
import time

optionssh = " -o Batchmode=yes"\
            " -o ConnectTimeout=5"\
            " -o IdentityFile=/root/.ssh/id_rsa"\
            " -o StrictHostKeyChecking=no"\
            " -o UserKnownHostsFile=/dev/null"\
            " -o PasswordAuthentication=no"\
            " -o ServerAliveInterval=10"\
            " -o CheckHostIP=no "

#local name file to reinstall
namefiletotransfert = "utils.py"
#remote file to change.
transfertou = "c:\\Python27\\Lib\\site-packages\\pulse_xmpp_agent\\lib\\utils.py"

namemachineok = "ipOK.txt"
namemachineko = "ipKO.txt"

def simplecommandstr(cmd):
    obj = {}
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    result = p.stdout.readlines()
    obj['code'] = p.wait()
    obj['result'] = "\n".join(result)
    return obj

def simplecommand(cmd):
    obj = {}
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    result = p.stdout.readlines()
    obj['code'] = p.wait()
    obj['result'] = result
    return obj

if __name__ == "__main__":
    if len (sys.argv) < 2 :
        print "name fichier missing"
        sys.exit(1)
    print "Transfert File %s to %s"%(namefiletotransfert, transfertou)
    f = open(sys.argv[1])
    lines = f.readlines()
    f.close()

    filenamemachineok = open(namemachineok, "a")
    filenamemachineko = open(namemachineko, "w")
    for t in lines:
        l = t.replace('|','').strip(" ")
        ip = re.findall(  r'[0-9]+(?:\.[0-9]+){3}', l )
        if len(ip) > 0:
            cmd ='scp %s %s pulse@%s:\"%s\"'%(optionssh, namefiletotransfert,ip[0],transfertou)
            obj = simplecommand(cmd)
            if obj['code'] != 0:
                print "Transfert KO for ip %s"%ip[0]
                filenamemachineko.write(str(ip[0])+"\n")
            else:
                filenamemachineok.write(str(ip[0])+"\n")
                print "Transfert OK for ip %s"%ip[0]
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,ip[0],'taskkill /F /IM python.exe')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,ip[0],'schtasks /end /TN "Pulse Agent"')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,ip[0],'schtasks /Run /TN "Pulse Agent"')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,ip[0],'tasklist ')
                obj = simplecommand(cmd)
                for i in obj["result"]:
                    if "python" in i:
                        print "OK"
    filenamemachineok.close()
    filenamemachineko.close()
