#!/bin/bash

#Author : Minotauro

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=nonintercative

trap ctrl_c INT

function ctrl_c(){

	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"
	tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>$1
	exit 0
	tput cnorm; exit 0
}

function helpPanel(){
	echo -e "\n${yellowColour}[*]${endColour}${blueColour} Uso ./scripting.sh${endColour}"
	echo -e "\t${purpleColour}a)${endColour}${yellowColour} Modo de ataque${endColour}"
	echo -e "\t\t${redColour}HandShake${endColour}"
	echo -e "\t\t${redColour}PKMID${endColour}"
	echo -e "\t${purpleColour}n)${endColour}${yellowColour} Nombre de la tarjeta de red${endColour}"
	exit 0
}

function dependencies(){
	tput civis
	clear
	dependencies=(aircrack-ng macchanger)
	echo -e "${yellowColour}[+]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -ne "\n${yellowColour}[+]${endColour}${blueColour} Herramienta ${endColour}${purpleColour}$program${endColour}${blueColour}...${endColour}"
		test -f /usr/bin/$program
		if [ "$(echo $?)" == "0" ]; then
		    echo -e " ${greenColour}(V)${endColour}"
		else
		    echo -e "${greenColour}(X)${endColour}"
		    
		    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Instalando herramienta${endColour}${blueColour} $program${endColour}${yellowColour}...${endColour}"
		    apt-get install $program -y > /dev/null 2>&1
		fi; sleep 1
	done
}

function startAttack(){
	clear
	echo -e "${yellowColour}[*]${endColour}${grayColour} Configurando tarjeta de red en modo monitor${endColour}\n"
	airmon-ng start  $networkCard > /dev/null 2>&1
	ifconfig ${networkCard}mon down && macchanger -a ${networkCard}mon > /dev/null 2>&1
	ifconfig ${networkCard}mon up ; killall dhclient wpa_supplicant 2 >/dev/null
	
	echo -e "${yellowColour}[+]${endColour}${grayColour} Nueva direccion ${endColour}${blueColour}$(macchanger -s ${networkCard}mon | grep -i current | xargs | cut -d ' ' -f '3-100')${endColour}"
}

#Main function

if [ "$(id -u)" == "0" ]; then
	clear
	declare -i parameter_counter=0; while getopts "a:n:h:" arg; do
	     case $arg in
		a) attack_mode = $OPTARG; let parameter_counter+=1 ;;
		n) networkCard = $OPTARG; let parameter_counter+=1 ;;
		h) helpPanel ;;
	     esac
	echo "soy root"
	done
	if [ $parameter_counter -ne 2 ]; then
		helpPanel
            else
		dependencies
		startAttack
		tput cnorm ; airmon-ng stop ${networkCard}mon > /dev/null 2>&i
         	fi
else
	clear
	echo -e "${redColour}[+] no soy ${endColour} \n"
fi

