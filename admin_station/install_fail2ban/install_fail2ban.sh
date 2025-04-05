#!/bin/bash
# ===============================
#  name: install_fail2ban.sh
#
#  description: installing fail2ban on the machine
#  and configuring a filter and ban for failed ssh-login attempts to the ssh-server.
#  The script checks for existing configurations on the machine. If there is an
#  existing [sshd] config in jail.local, it is not overwritten and the scripts exits
#
#  tested under: Debian GNU/Linux 12 (bookworm), Ubuntu 24.04.2 LTS, fail2ban Version: 1.1.0
#  
# ===============================

# uncomment next line for debugging
#set -x #tracing-option


#if fail2ban is not installed, install it
if apt list --installed | grep fail2ban || [ -d /etc/fail2ban ]
then
	echo "fail2ban is already installed, proceed..."
	
else
	#install fail2ban
	apt install fail2ban
	#check now, if installation worked
	if [ $? -ne 0 ] || [ ! -d /etc/fail2ban ]
	then
		echo "Error: fail2ban could not be installed"
		exit 1
	else
		echo "fail2ban was successfully installed"
	fi
fi


#change to fail2ban config-directory
cd /etc/fail2ban


#if the file jail.local doesnt exists already
if [ ! -e "jail.local" ]
then
	#if jail.local doesnt exists, create it, by copying jail.conf
	#all configs should be made to jail.local because jail.conf can be overwritten
	cp jail.conf jail.local
	#check now, if jail.local was created
	if [ $? -ne 0 ] || [ ! -e "jail.local" ]
	then
		echo "Error: jail.local could not be created"
		exit 1
	else
		echo "jail.local was created"
	fi
fi


#check, if there is an sshd-configuration in jail.local already 
if cat jail.local | grep "\[sshd\]"
then
	echo "there is already an exisiting [sshd] configuration, exiting script"
	exit 1
fi


#append sshd-config to jail.local file
printf "

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/fail2ban.log
maxretry = 3
action  = iptables[name=sshd, port=ssh]
bantime  = 3m " >> jail.local

if [ $? -eq 0 ]
then
	echo "config was successfully written to jail.local"
fi

#create log-file manually, otherwise fail2ban complains
touch /var/log/fail2ban.log

#enable service
systemctl enable fail2ban

#restart fail2ban.service 
systemctl restart fail2ban

#check exit status of status
if systemctl status --no-pager fail2ban
then
	echo "fail2ban status okay"
	exit 0
else
	echo "fail2ban status NOT okay"
	exit 1
fi



