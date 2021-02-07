#!/usr/bin/bash

while :
do
opcion=0

echo "1 ip"
echo "2 targeta"
echo -e "3 salir\n"

echo -n "Elige una opcion :"
read opcion
case $opcion in

1)
ifconfig
read enterkey
;;
2)
iwconfig
read enterkey
;;
3)
exit 0
read enterkey
echo "la opcion no esta disponible" 
read enterkey 
;;
esac
done
