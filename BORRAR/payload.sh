#!/usr/bin/bash

trap Ctrl_c INT

function Ctrl_c(){ 
        sleep 3s
        echo "cerrando programa"
        limpiar_pantalla
        exit 0
}

function limpiar_pantalla {
	clear
}

echo -e "\e[0;31mderechos de autor MinoTauro\e["
sleep 2
limpiar_pantalla
echo -e "\e[0;31mvamos a escanear , introduce la ip\e["
sleep 2
read ip
read -p "que puertos :" o
limpiar_pantalla
dirbuster $ip 
sleep 3m



