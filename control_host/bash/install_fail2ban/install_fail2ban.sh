#!/bin/bash
# ===============================
#  name: install_fail2ban.sh
#
#  usage: ./install_fail2ban.sh <MAX_RETRY> [--selfdelete]
#
#  description: installing fail2ban on the machine
#  and configuring a filter and ban for failed ssh-login attempts to the ssh-server.
#  The script checks for existing configurations on the machine. If there is an
#  existing [sshd] config in jail.local, it is not overwritten and the scripts exits
#  
#  parameters:
#
#  MAX_RETRY: determines the number of failed ssh-login attempts are needed for a ban to be activated
#  --selfdelete: if this option is provided, this script deletes itself after execution
#
#  tested under: Debian GNU/Linux 12 (bookworm), Ubuntu 24.04.2 LTS, fail2ban Version: 1.1.0
#  
# ===============================

# uncomment next line for debugging
#set -x #tracing-option

CONFIG_FILE="/etc/fail2ban/jail.d/customisation.local"
MAX_RETRY=0
SELF_DELETE=FALSE
SCRIPT_LOCATION=$(pwd)

#functions that self-deletes this script, if SELF_DELETE as value "TRUE"
#parameter $1: exit-status
function exit_script () {
	
	EXIT_STATUS=$1
	
	
	if [ "$SELF_DELETE" = "TRUE" ]
	then
		cd $SCRIPT_LOCATION
		#self-deletes this script
		rm -- "$0"
	fi
	
	#exit this script
	exit $EXIT_STATUS	
}

#check, if a parameter for the number of max retries was provided
if [ -z $1 ]
then
	printf "please provide the number of maximal retries for fail2ban as the first parameter"
	exit_script 1
else
	MAX_RETRY=$1
fi

#if there was a second parameter provided
if [ ! -z $2 ]
then
	if [ $2 = "--selfdelete" ]
	then
		SELF_DELETE=TRUE
	else 
		printf "\nError: An unkown second parameter %s was provided\n" $2
		exit_script 1
	fi
fi


#if fail2ban is not installed, install it
if apt list --installed 2> /dev/null | grep fail2ban &> /dev/null || [ -d /etc/fail2ban ] 2> /dev/null
then
	echo "fail2ban is already installed, proceed..."
	
else
	#install fail2ban
	apt install fail2ban
	#check now, if installation worked
	if [ $? -ne 0 ] || [ ! -d /etc/fail2ban ]
	then
		echo "Error: fail2ban could not be installed"
		exit_script 1
	else
		echo "fail2ban was successfully installed"
	fi
fi

#change to fail2ban config-directory
cd /etc/fail2ban


#if the CONFIG_FILE doesnt exists already
if [ ! -e $CONFIG_FILE ]
then
	#if CONFIG_FILE doesnt exists, create it
	touch $CONFIG_FILE
	#check now, if CONFIG_FILE was created
	if [ $? -ne 0 ] || [ ! -e $CONFIG_FILE ]
	then
		echo "Error: $CONFIG_FILE could not be created"
		exit_script 1
	else
		echo "$CONFIG_FILE was created"
	fi
fi


#check, if there is an sshd-configuration in jail.local already 
if cat $CONFIG_FILE | grep "\[sshd\]"  &> /dev/null
then
	echo "there is already an exisiting [sshd] configuration, exiting script"
	exit_script 1
fi


#append sshd-config to CONFIG_FILE
printf "
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = $MAX_RETRY
action  = iptables[name=sshd, port=ssh]
bantime  = 3m " >> $CONFIG_FILE

if [ $? -eq 0 ]
then
	echo "config was successfully written to $CONFIG_FILE"
fi

#enable service
systemctl enable fail2ban

#restart fail2ban.service 
systemctl restart fail2ban

#check exit status of status
if systemctl status --no-pager fail2ban &> /dev/null
then
	echo "fail2ban status okay"
	exit_script 0
else
	echo "fail2ban status NOT okay"
	exit_script 1
fi


