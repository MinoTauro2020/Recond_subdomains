#!/usr/bin/bash

options="Subdomains Ports Subdomains-and-Ports"

trap ctrl_c INT

function ctrl_c(){
	clear
	echo "Exit"
	sleep 2
	exit 0
}

function checktools(){

  dependencies=(html2text jq)

	for program in $dependencies ; do
	test -f /usr/bin/$program
	if ["$(echo $?)" == "0"] ; then
	echo "no esta instalada";
	sleep 2
	echo "installing"
	apt-get install html2text
	echo "finish"
	else
	echo "All tools are installed OK!"
	fi;
	done

}

function CheckHost(){

	clear
	echo "Checking hosts alive"
	cat $host-sub-total | httpx -silent | tee $host-alive

}


select opcion in $options;

do

	if [ $opcion = "Subdomains" ]; then
		clear
		echo -n "Write the domain name : "
		read host
		echo "0%"
		curl -s -d  domain=$host  -X POST https://osint.sh/subdomain/ | grep -Eo '(http|https)://[^/"]+' | grep $host >> $host-sub
		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $host-sub
		curl -s "https://dns.bufferover.run/dns?q=.$host" |jq -r .FDNS_A[] | sed -s 's/,/\n/g' >> $host-sub
		curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$host"|jq -r '.subdomains' 2>/dev/null |grep -o "\w.*$host" | tr -d "\"," >> $host-sub
		curl -s "https://api.hackertarget.com/hostsearch/?q=$host" |grep -o "\w.*$host" >> $host-sub
		curl -s "https://rapiddns.io/subdomain/$host?full=1"  | grep -oP '_blank">\K[^<]*' >> $host-sub
		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub
		curl -s "https://crt.sh/?CN=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub
		curl -s "https://riddler.io/search/exportcsv?q=pld:$host" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> $host-sub
		curl -s "https://securitytrails.com/list/apex_domain/$host" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$host" | sort -u >> $host-sub
		cat $host-sub | sort -u | uniq | tee $host-sub-total
		sleep 1
		wc -l $host-sub-total ; echo "Founded"
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








