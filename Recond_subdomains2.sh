#!/usr/bin/bash

options="Subdomains Ports Subdomains-and-Ports"

trap ctrl_c INT

function ctrl_c(){

		clear

		echo "Exit"

		sleep 2

		exit 0
}

function finish(){

	echo -e "\n[+] Finish Recon Check Files : "

}


function JS_Extraction(){

		clear

		echo -e "\n[+] Extracting JS Files"

		sleep 2

		cat $target-alive | subjs | tee $target-JS

		echo -e "\n[+] Extracting params and urls from js"

		finish


}


function SensitiveInformation(){

		clear

		echo -e "\n[+] Extracting SensitiveInformation"

		cat $target-endpointsC

		grapX $target-endpointsC $target-sensitiveinformation

		cat $target-sensitiveinformation

		echo -e "\n[+]Check File $target-sensitiveinformation"

		JS_Extraction

}

function EndPoints_Extraction(){

		clear

		echo "$target"

		echo -e "\nExtraction endpoints with gau waybackurls"

		echo -e "\n0%"

		echo "$target" | gau | egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $target-endpoints

		echo -e "\n50%"

		echo "$target"  | waybackurls |  egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $target-endpoints
		
		echo -e "\n[+] Searching interesting params sql xss rce "
		
		cat $target-endpoints | gf sqli | sort -u | uniq | tee $target-endpoints-sqli
		
		cat $target-endpoints | gf xss  | sort -u | uniq | tee $target-endpoints-xss
		
		cat $target-endpoints | gf rce  | sort -u | uniq | tee $target-endpoints-rce
		
		cat $target-endpoints | gf ssti | sort -u | uniq | tee $target-endpoints-redirec
		
		echo -e "\nCleaning Duplicates"

		cat "$target-endpoints" | sort -u | uniq | tee $target-endpointsC 

		echo -e "\n100% done"

        	SensitiveInformation
}

function Nuclei_Attack(){

		clear

		echo "Updating Templates"

		nuclei -update-templates

		echo "=======Nuclei Attack======="

        	echo -e "\n0% Checking CVE's"

		cat $target-alive | nuclei -t /root/nuclei-templates/   | tee $target-nuclei

		

}


function CheckHost(){

		clear

		echo "Checking hosts alive"

		cat $target-sub-total | httpx -silent -ports 80,443,8080,8443 | sort -u | uniq | tee $target-alive

    		wc -l $target-alive

		Nuclei_Attack

}

function Subdomains(){

		clear

		curl -s -d  domain=$target  -X POST https://osint.sh/subdomain/ | grep -Eo '(http|https)://[^/"]+' | grep $target >> $target-sub

		echo "10%"

		curl -s "https://crt.sh/?q=%25.$target&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $target-sub

		echo "20%"

		curl -s "https://dns.bufferover.run/dns?q=.$target" |jq -r .FDNS_A[] | sed -s 's/,/\n/g' >> $target-sub

		echo "30%"

		curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$target"|jq -r '.subdomains' 2>/dev/null |grep -o "\w.*$target" | tr -d "\"," >> $target-sub
		curl -s "https://sonar.omnisint.io/subdomains/$target" | tr -d "\"" | tr -d "\," | awk ' { print $1 } ' | tr -d "\]"  >> $target-sub


		echo "40%"

		curl -s "https://api.hackertarget.com/hostsearch/?q=$target" |grep -o "\w.*$target" >> $target-sub

		echo "50%"

		curl -s "https://rapiddns.io/subdomain/$target?full=1"  | grep -oP '_blank">\K[^<]*' >> $target-sub

		echo "60%"

		curl -s "https://crt.sh/?q=%25.$target&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $target-sub

		echo "70%"

		curl -s "https://crt.sh/?CN=%25.$target&output=json" | jq -r '.[].name_value' | sed 's/\*.//' >> $target-sub

		echo "80%"

		curl -s "https://riddler.io/search/exportcsv?q=pld:$target" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> $target-sub

		echo "90%"

		curl -s "https://securitytrails.com/list/apex_domain/$target" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$target" | sort -u >> $target-sub

		echo "100"

		cat $target-sub | sort -u | uniq | tee $target-sub-total

		clear

		echo -e "\n======Totals====="

		wc -l $target-sub-total

                echo -e "\n[+] Checking domains alive"

                CheckHost


}

while getopts ":T:Ah" opt; do

	case ${opt} in

		T ) target=$OPTARG

		    ;;
 
		A ) Subdomains

		    ;;

			        

		\? | h ) echo "Usage  :";

			 echo "         -T	Name of Target ";
 
			 echo "         -A	Extract Subdomains + LiveDomains + Check Vulnerabilities + EndpointsExtracion + SensitiveFiles";
 
		         ;;
 
		: ) echo "Invalid Argument";

		     ;;

	esac

done

shift $((OPTIND -1))





