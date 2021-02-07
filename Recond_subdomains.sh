#!/usr/bin/bash

options="Subdomains Ports Subdomains-and-Ports"

trap ctrl_c INT

function ctrl_c(){
	clear
	echo "Exit"
	sleep 2
	exit 0
}


function CheckHost(){

	clear

	echo "Checking hosts alive"

	cat $host-sub-total | httpx -silent | tee $host-alive

	wc -l $host-alive

	echo -n "Do you want to use nuclei to find vulnerabilities: "

	read answer

	if [ $answer =="yes"]
        then
	echo "ha elegido yes"
	else
	echo "ha elegido no"
	fi

}

select opcion in $options;

do

	if [ $opcion = "Subdomains" ]; then
		clear
		echo -n "Write the domain name : "
		read host

		echo "0%"

		curl -s -d  domain=$host  -X POST https://osint.sh/subdomain/ | grep -Eo '(http|https)://[^/"]+' | grep $host >> $host-sub

		echo "10%"

		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $host-sub
		
		echo "20%"

		curl -s "https://dns.bufferover.run/dns?q=.$host" |jq -r .FDNS_A[] | sed -s 's/,/\n/g' >> $host-sub

		echo "30%"

		curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$host"|jq -r '.subdomains' 2>/dev/null |grep -o "\w.*$host" | tr -d "\"," >> $host-sub

		echo "40%"

		curl -s "https://api.hackertarget.com/hostsearch/?q=$host" |grep -o "\w.*$host" >> $host-sub

		echo "50%"

		curl -s "https://rapiddns.io/subdomain/$host?full=1"  | grep -oP '_blank">\K[^<]*' >> $host-sub

		echo "60%"

		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub

		echo "70%"

		curl -s "https://crt.sh/?CN=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub

		echo "80%"

		curl -s "https://riddler.io/search/exportcsv?q=pld:$host" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> $host-sub

		echo "90%"

		curl -s "https://securitytrails.com/list/apex_domain/$host" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$host" | sort -u >> $host-sub

		echo "100"

		cat $host-sub | sort -u | uniq | tee $host-sub-total

		wc -l $host-sub-total && echo "Founded"

		sleep 5

		echo "===Checking hosts alive===="

		CheckHost

	elif [ $opcion = "Ports" ]; then

		clear
		echo -n "Write the domain name : "
		read host
		curl -s -d domain=$host -X POST https://osint.sh/nmap/ | html2text | grep tcp 

	elif [ $opcion = "Subdomains-and-Ports" ]; then

		clear
		echo -n "Write the domain name : "
		read host
		curl -s -d  domain=$host  -X POST https://osint.sh/subdomain/ | grep -Eo '(http|https)://[^/"]+' | grep $host >> $host
		cat $host | while read hosts ; do  curl -s -d domain=$hosts -X POST https://osint.sh/nmap/ | html2text | grep tcp ; done | tee $hosts_ip

	fi
done








