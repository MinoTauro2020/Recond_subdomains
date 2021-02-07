#!/bin/bash

program=(nuclei httpx nikto puta)

for programas in program ; do
	test -f /usr/bin/$programas
	if [ "$(echo $?)" == "0" ]; then
        	echo "No estan"
	else
		echo "Si estan"

	fi
done
