#!/usr/bin/bash

trap Ctrl_c INT

function Ctrl_c(){
	sleep 3s
	echo "cerrando programa"
	sleep 3s
	cerrado
	exit 0
}

function cerrado {
	clear
}
sleep 3s
echo -n "buenas como estas : "
sleep 3s
cerrado
echo "como estas"

function dirbuster {
echo "dirbuster" $url 
}
sleep 3s




