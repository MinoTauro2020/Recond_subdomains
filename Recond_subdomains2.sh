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

		clear

		echo -e "\nChecking is Host Alive"

		echo "$target" | httpx -silent | tee $target-L

		echo -e "\nExtracting JS"

		echo "$target-L" | subjs

		echo -e "\nExtracting Endpoints"

		echo "$target-L" | getJS -complete | tee $target-JS

	  	rm "$target-L"

}


function SensitiveInformation(){

		clear

		echo -e "\n[+] Extracting SensitiveInformation"

		cat $target-endpointsC

		grapX $target-endpointsC $target-sensitiveinformation

		cat $target-sensitiveinformation

		echo -e "\n[+]Check File $target-sensitiveinformation"

}

function EndPoints_Extraction(){

		clear

		echo "$target"

		echo -e "\nExtraction endpoints with gau waybackurls"

		echo -e "\n0%"

		echo "$target" | gau | egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $target-endpoints

		echo -e "\n50%"

		echo "$target"  | waybackurls |  egrep -v '(.css|.png|.jpeg|.jpg|.svg|.gif|.wolf)' >> $target-endpoints

		echo -e "\nCleaning Duplicates"

		cat "$target-endpoints" | sort -u | uniq | tee $target-endpointsC 

		rm $target-endpoints

		echo -e "\n100% done"

        	cat $target-endpointsC

		echo -e "\nView Files $targets-endpointsC"

		echo -n "[+] Would you like to extrac sensitive information : "

		read $answerSI

		if [ "$answerSI==yes" ]; then

		echo -e "\n[+] yes? OK!"

		SensitiveInformation

		else echo "no"

		crtl_c

		fi
}

function Nuclei_Attack(){

		clear

		echo "Updating Templates"

		nuclei -update-templates

		echo "=======Nuclei Attack======="

        	echo -e "\n0% Checking CVE's"

		echo $target | httpx -silent | nuclei -t /root/nuclei-templates/cves  | tee $target-cves

		echo -e "\n33% Checking vulnerabilities"

		echo $target | nuclei -t /root/nuclei-templates/vulnerabilities  | tee $target-vulnerabilities

		echo -e "\n66% Checking Technologies"
	
		cat $target  | nuclei -t /root/nuclei-templates/technologies | tee $target-technologies

		echo -e "\n100%"

		echo -e "\nCheck Files $target-cves $target-vulnerabilities $target-technologies"

}


function CheckHost(){

		clear

		echo "Checking hosts alive"

		cat $target-sub-total | httpx -silent | tee $target-alive

		wc -l $target-alive

		echo -n "\nDo you want to use Nuclei to find vulnerabilities : "

		read respuesta

		if [ $respuesta == yes ];then

	        Nuclei_Attack

                else 

		echo "EXIT"

		ctrc_c 

		fi

		exit 0
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

while getopts ":T:REAJh" opt; do

	case ${opt} in

		T ) target=$OPTARG
		
		    ;;
		    
		R ) Subdomains
		
		    ;;
		    
		E ) EndPoints_Extraction
		
		    ;;
		    
		A ) Nuclei_Attack
		
		    ;;
		    
		J ) JS_Extraction 
		
		    ;;    
		    
		\? | h ) echo "Usage  :";
		
			 echo "         -T	Name of Target ";
			 
			 echo "         -R	Extract Subdomains ";
			 
			 echo "         -E	Extract urls from archive.org ";
			 
			 echo "         -J	Extract JS  ";
			 
			 echo "         -A	Extract Vulnerabilities Technologies CVE's ";
			 
			 echo "         -F       Full Recon ";
			 
			 echo "         -h	Displays the usage details";
			 
		         ;;
		         
		: ) echo "Invalid Argument";

		     ;;

	esac

done

shift $((OPTIND -1))











