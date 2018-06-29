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

le script present travaille avec un fichier possédant une liste de noms de machine en entree

il est généré 2 fichiers en sortie.
le fichier des machines    ok
et le fichier des machines ko.

permettant de reproduire le script sur les machines ko uniquement.

Methode pour récupérer les mons des machines en liste. 
creation d'un groupe sur pulse, récupérer le cvs. conserver seulement la colonne nom.
"""

# fichier ip.txt result de SELECT distinct name FROM glpi.glpi_ipaddresses where name like "10.%";
# cat  `ls /var/log/mmc/mmc-agent*` | grep xmppip | grep "10.1" | grep -v DEBUG | awk '{print $7}' | sort | uniq > /root/ipadress.txt

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

namemachineok = "machineOK.txt"
namemachineko = "machineKO.txt"

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

    print lines
    for t in lines:
        if t != "":
            t = t.replace('\n',"")
            cmd ='scp %s %s pulse@%s:\"%s\"'%(optionssh, namefiletotransfert,t,transfertou)
            obj = simplecommand(cmd)
            if obj['code'] != 0:
                print "Transfert KO for ip %s"%t
                filenamemachineko.write(str(t)+"\n")
            else:
                filenamemachineok.write(str(t)+"\n")
                print "Transfert OK for ip %s"%t
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,t,'taskkill /F /IM python.exe')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,t,'schtasks /end /TN "Pulse Agent"')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,t,'schtasks /Run /TN "Pulse Agent"')
                obj = simplecommand(cmd)
                cmd ='ssh %s pulse@%s \'%s\''%(optionssh,t,'tasklist ')
                obj = simplecommand(cmd)
                for i in obj["result"]:
                    if "python" in i:
                        print "OK"
    filenamemachineok.close()
    filenamemachineko.close()
