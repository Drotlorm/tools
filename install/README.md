# Pulse Installation

[Pulse](http://www.siveo.net) is a radically simple IT automation and lifecycle management tool.

![Pulse Logo](https://avatars3.githubusercontent.com/u/15610175)
## Requirements
* Debian Jessie or Stretch

## Glpi compatibility
* Up to GLPI 9.1.6

## Quick installation from devel branch



Download install-pulse-git and run

```
# wget  https://raw.githubusercontent.com/pulse-project/tools/master/install/install-pulse-git
# source install-pulse-git 
```

### Usage:

source install-pulse-git [--batch-mode [arguments]] | [--interactive-mode] 

### Arguments:
```
	[--pulse-repo-url=<pulse repo url>]
  
	[--root-password=<root password>]
  
	[--org-name=<organization name>]
  
	[--server-fqdn=<FQDN of server>]
  
	[--interface-to-clients=<interface>]
  
	[--enable-pulse-main=[g]lpi[d]hcp|[p]xe | --enable-multisite=[d]hcp|[p]xe|[b]ackuppc]
  
	[--create-entity]
  
	[--entity=<entity name>]
  
	[--dhcp-dns-server=<dns server for DHCP clients>]
  
	[--dhcp-gateway-address=<gateway address for DHCP clients>]
  
	[--interface-to-main-pulse=<interface>]
  
	[--main-pulse-ip=<IP address>]
  
	[--glpi-url=<GLPI URL>]
  
	[--glpi-dbhost=<IP address>]
  
	[--glpi-dbname=<database name>]
  
	[--glpi-dbuser=<database username>]
  
	[--glpi-dbpasswd=<database user password>]
  
	[--glpi-dbrootpasswd=<mysql root password>]
  
	[--mail-password=<support mail account password>]

	[--branch=<devel branche to use>]
```
### Exemple : Pulse monosite 
```source install-pulse-git --batch-mode --pulse-repo-url="https://git.siveo.net" --root-password=siveo --org-name=Siveo --interface-to-clients=eth1 --enable-pulse-main=dpg --create-entity --entity=HQ --dhcp-dns-server="8.8.8.8" --dhcp-gateway-address="192.168.56.2"```

### Exemple : Pulse monosite with special dev branch
```source install-pulse-git --batch-mode --pulse-repo-url="https://git.siveo.net" --root-password=siveo --org-name=Siveo --interface-to-clients=eth1 --enable-pulse-main=dpg --create-entity --entity=HQ --dhcp-dns-server="8.8.8.8" --dhcp-gateway-address="192.168.56.2" --branch="special_branch"```

### Exemple : Pulse monosite with external GLPI
```source install-pulse-git --batch-mode --pulse-repo-url="https://git.siveo.net" --root-password=siveo --org-name=Siveo --interface-to-clients=eth0 --enable-pulse-main=gdp --entity=HQ --dhcp-dns-server="8.8.8.8" --dhcp-gateway-address="192.168.56.1" --glpi-url="http://192.168.56.100/glpi" --glpi-dbhost="192.168.56.100" --glpi-dbuser=glpi --glpi-dbpasswd=siveo --glpi-dbname=glpi```

### Exemple : Pulse multisite with external GLPI link the main Pulse
```source install-pulse-git --batch-mode --pulse-repo-url="https://git.siveo.net" --root-password=siveo --org-name=Siveo --interface-to-clients=eth1 --enable-multisite=dpb --entity="annecy auber" --dhcp-dns-server="8.8.8.8" --dhcp-gateway-address="192.168.56.1" --interface-to-main-pulse=eth0 --main-pulse-ip="192.168.56.2" --glpi-dbhost="192.168.56.100" --glpi-dbuser=glpi --glpi-dbpasswd=siveo --glpi-dbname=glpi```

## IRC Chat

You can start a conversation with our comunity here. If you have any problem, or any question, do not hesitate! We are friendly.

server : irc.freenode.net channel : #pulse-fr, #pulse-en



## Warning
* git version software. Might or might not work as expected. 
* Keep in mind that install-pulse-git is updated on a regular basis. Do download the latest version before use.
