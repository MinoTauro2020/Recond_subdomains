#!/usr/bin/bash

options="Subdomains Ports Subdomains-and-Ports"

select opcion in $options;

do

	if [ $opcion = "Subdomains" ]; then

		clear
		echo -n "Write the domain name : "
		read host
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








