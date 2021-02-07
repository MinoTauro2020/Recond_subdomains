#!/usr/bin/bash

options="Subdomains Ports Subdomains-and-Ports"

trap ctrl_c INT

function ctrl_c(){
	clear
	echo "Exit"
	sleep 2
	exit 0
}

function JS_Extraction(){

	echo -e "\n Extract JS"

	cat $host-alive | getJS -complete

}

function EndPoints_Extraction(){

	echo -e "\nExtraction endpoints with gau waybackurls"
	echo -e "\n0%"
#	cat $host-alive | gau | egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $host-endpoints
	echo -e "\n50%"
#	cat $host-alive | waybackurls |  egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $host-endpoints
	echo -e "\nCleanin Duplicates"
#	cat $host-endpoints | sort -u | uniq | tee $host-endpointsC 
	rm $host-endpoints
	echo -e "\n100% done"
	echo -e "\nView Files $hosts-endpointsC"
}

function Nuclei_Attack(){

	clear

	echo "=======Nuclei Attack======="

        echo -e "\n0% Checking CVE's"

#	cat $host-alive | nuclei -t /root/nuclei-templates/cves | tee $host-CVEs

	echo -e "\n33% Checking vulnerabilities"

#	cat $host-alive | nuclei -t /root/nuclei-templates/vulnerabilities | tee $host-vulnerabilities

	echo -e "\n66% Checking Technologies"

#	cat $host-alive | nuclei -t /root/nuclei-templates/technologies | tee $host-technologies

	echo -e "\n100%"

	echo -e "\nCheck Files $host-CVEs $host-vulnerabilities $host-technologies"

	EndPoints_Extraction
}


function CheckHost(){

	clear

	echo "Checking hosts alive"

	cat $host-sub-total | httpx -silent | tee $host-alive

	wc -l $host-alive

	echo -e "\nDo you want to use Nuclei to find vulnerabilities : "

	read respuesta

	if [ $respuesta == yes ];then

		 echo "Write yes, if you want to continue";

		 Nuclei_Attack

             else echo "go to the principal Menu"; fi

             exit 0
}

function Menu(){

select opcion in $options;

do

	if [ $opcion = "Subdomains" ]; then

		clear

		echo -n "Write the domain name : "

		read host

		echo "0%"

#		curl -s -d  domain=$host  -X POST https://osint.sh/subdomain/ | grep -Eo '(http|https)://[^/"]+' | grep $host >> $host-sub

		echo "10%"

#		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $host-sub
		
		echo "20%"

#		curl -s "https://dns.bufferover.run/dns?q=.$host" |jq -r .FDNS_A[] | sed -s 's/,/\n/g' >> $host-sub

		echo "30%"

#		curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$host"|jq -r '.subdomains' 2>/dev/null |grep -o "\w.*$host" | tr -d "\"," >> $host-sub

		echo "40%"

#		curl -s "https://api.hackertarget.com/hostsearch/?q=$host" |grep -o "\w.*$host" >> $host-sub

		echo "50%"

#		curl -s "https://rapiddns.io/subdomain/$host?full=1"  | grep -oP '_blank">\K[^<]*' >> $host-sub

		echo "60%"

#		curl -s "https://crt.sh/?q=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub

		echo "70%"

#		curl -s "https://crt.sh/?CN=%25.$host&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $host-sub

		echo "80%"

#		curl -s "https://riddler.io/search/exportcsv?q=pld:$host" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> $host-sub

		echo "90%"

#		curl -s "https://securitytrails.com/list/apex_domain/$host" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$host" | sort -u >> $host-sub

		echo "100"

		cat $host-sub | sort -u | uniq | tee $host-sub-total

		echo -e "\n======Totales===== wc -l $host-sub-total"

		sleep 3

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

}

Menu











