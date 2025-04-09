#!/bin/bash
# ===============================
#  name: deploy_and_test_fail2ban.sh 
#
# description: deploying the script install_fail2ban.sh on a number of servers that are written in hostlist.txt
# For every host, the script install_fail2ban.sh is copied and executed on the machine
# if the installation and configuration of fail2ban was succesfull, fail2ban is being tested
# the test is made by doing a number of invalid ssh-login attempts until the ban should be in place
# then a valid ssh-login attempt should fail
#
# tested under: Debian GNU/Linux 12 (bookworm), Ubuntu 24.04.2 LTS, fail2ban Version: 1.1.0
#
# ===============================

# uncomment next line for debugging
# set -x #tracing-option

#list of hosts, format user@ip-adress
HOSTLIST="hostlist.txt"

#directory, where the script on server is executed
DIR="/var/tmp/"

#installation script
INSTALLATION_SCRIPT="install_fail2ban.sh"

#Number of max retries, before the ban is activated
MAX_RETRY=3

if [ ! -e $HOSTLIST ]
then
	echo "a hostlist doenst exists"
	exit 1
fi

#iterate over hosts
for HOST in $( cat $HOSTLIST )
do

    #extract ip-adress from host
    ip=$( printf $HOST | cut -d "@" -f 2 )

    #copy installation script to server
    scp "$INSTALLATION_SCRIPT" "$HOST:$DIR" &> /dev/null
    #execute installation script on server
    ssh $HOST "cd $DIR ; sudo -S ./$INSTALLATION_SCRIPT $MAX_RETRY"
    
    #if installation was not successful, remuse with next host
    if [ $? -ne 0 ]
    then
    	printf "the installation of fail2ban was not successful, resume with next host...\n"
    	continue
    fi
    
    
    #now do invalid ssh-login attempts to trigger ban
    for (( var=0 ; var < $MAX_RETRY ; var++ ))
    do
    	printf "\nDo an invalid ssh login attempt:\n"
	#invalid ssh login attempt
	ssh invaliduser123@$ip
	#sleep command is important here, otherwise connection could fail simply because too many requests too fast
	sleep 1
    done
    
    #now do a valid ssh command
    printf "\nDo a valid ssh login attempt:\n"
  
    ssh $HOST "exit"

    
    #test now, if the ssh attempt with valid credentials was refused
    if [ $? -ne 0 ]
    then
    	printf "\nThe fail2ban test was successful for $HOST .\n"
    	printf "This Client is now banned from the server for the duration that was set in $INSTALLATION_SCRIPT\n"
    else
    	printf "\nWARNING: The fail2ban test was  NOT successful for $HOST. Please check manually for errors\n\n"
    fi

done


exit 0

