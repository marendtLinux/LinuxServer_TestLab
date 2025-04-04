#!/bin/bash

# ===============================
#  name: create_bashscript.sh
#
#  Description: a bashscript-template
#
# ===============================


if [ -z "$1" ]  # if scriptname wasnt submitted, exit
then
	echo "Error: please provide a scriptname as first argument"
	exit 1 
elif [ -e "$1" ] #if file already exists, exit
then
	echo "Error: a file with the name $1 already exits"
	exit 1 	
fi


#write header and create file 
printf "#!/bin/bash
# ===============================
#  name: $1
#
#  Description: 
#
# ===============================

# uncomment next line for debugging
# set -x #tracing-option

"  > $1


#make new script executable
chmod u+x $1




