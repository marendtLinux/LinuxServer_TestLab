#!/bin/bash
# ===============================
#  name: deploy_and_test_fail2ban.sh 
#
#  Description: 
#
# ===============================

# uncomment next line for debugging
# set -x #tracing-option

#list of hosts, format user@ip-adress
HOSTLIST="hostlist.txt"
#HOSTLIST="hostlist.txt"

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
    scp "$INSTALLATION_SCRIPT" "$HOST:$DIR"
    #execute installation script on server
    ssh $HOST "cd $DIR ; sudo -S ./$INSTALLATION_SCRIPT $MAX_RETRY"
    
    #now do invalid ssh-login attempts to trigger ban
    for (( var=0 ; var < $MAX_RETRY ; var++ ))
    do
    	printf "\nDo a invalid ssh login attempt:\n"
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
    	printf "\nThe fail2ban test was successful for $HOST .\n" \
    	"You are now banned from the server for the duration that was  set in $INSTALLATION_SCRIPT\n"
    else
    	printf "\nWARNING: The fail2ban test was  NOT successful for $HOST. Please check manually for errors\n\n"
    fi

done


exit 0

