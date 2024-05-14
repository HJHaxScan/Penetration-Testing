#!/bin/bash

#1. Getting the User Input
#1.1 Get from the user a network to scan.
#1.2 Get from the user a name for the output directory.
#1.3 Allow the user to choose 'Basic' or 'Full'.
#1.3.1 Basic: scans the network for TCP and UDP, including the service version and weak passwords.
#1.3.2 Full: include Nmap Scripting Engine (NSE), weak passwords, and vulnerability analysis.
#1.4 Make sure the input is valid.
#2. Weak Credentials
#2.1 Look for weak passwords used in the network for login services.
#2.1.1 Have a built-in password.lst to check for weak passwords.
#2.1.2 Allow the user to supply their own password list.
#2.2 Login services to check include: SSH, RDP, FTP, and TELNET.
#3. Mapping Vulnerabilities
#3.1 Mapping vulnerabilities should only take place if Full was chosen.
#3.2 Display potential vulnerabilities via NSE and Searchsploit.
#4. Log Results
#4.1 During each stage, display the stage in the terminal.
#4.2 At the end, show the user the found information.
#4.3 Allow the user to search inside the results.
#4.4 Allow to save all results into a Zip file.
#5. Creativity


#1.1 Get from the user a network to scan.


	# Get the user input for IP address

echo -e
echo -n "Please enter an IP address : "; read ip
echo -e

	# Use a regular expression to check if the input is a valid IP address

if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

    # Use an array to store the octets of the IP address
    IFS='.' read -ra octets <<< "$ip"

    # Check if each octet is between 0 and 255
    
    for octet in "${octets[@]}"; 
    
    do
    
        if [ $octet -lt 0 ] || [ $octet -gt 255 ]; 
        
			then
            echo "$ip is not a valid IP address. Please re-enter your target IP address."
            
            exit
            
        fi
        
    done

    echo "The IP address $ip is valid and will be use for scanning the target..."
    
else

    echo "$ip is not a valid IP address. Please re-enter your target IP address."
    
	exit
    
fi

echo -e


#1.2 Get from the user a name for the output directory.


echo "Please enter the directory you wish the results to be stored in..."
read dstdir

#Check if input is empty

if [ -z "$dstdir" ]; then

	echo -n "You left your previous input blank, Please enter the directory you wish the results to be stored in..."; read dstdir
	
	if [ -z "$dstdir" ]; then
		
		echo "No input detected, automatically creating folder in current directory to stored the results..."
		mkdir -p Results
		sleep 3
		echo "Results folder created..."
		dstdir=Results
	fi
	
else
	
	mkdir -p $dstdir
	echo "Results folder created..."
	
fi

echo -e


#1.3 Allow the user to choose 'Basic' or 'Full'.


echo "Please choose if you wish to do a Basic or Full vulnerability scan..."

while [[ $scanchoice != "basic" && $scanchoice != "full" ]]; do

echo -n "Your choice : "; read scanchoice

scanchoice=$(echo "$scanchoice" | tr '[:upper:]' '[:lower:]')

done

echo -e

#1.3.1 Basic: scans the network for TCP and UDP, including the service version and weak passwords.



	# Run Basic vulnerability scan command here
	
	
if [ $scanchoice == "basic" ]; then

	mkdir -p $dstdir/Scans
	echo "Running Basic Vulnerability Scan..."
	echo -e
	echo "Running Nmap Scanning Tool..."
	nmap -sV $ip -p- >> $dstdir/Scans/TCPresults.lst
	cat $dstdir/Scans/TCPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Nmap Scan completed..."
	echo -e
	echo "Running Masscan... Permission might be required"
	sudo masscan $ip -pU -p- --rate 500 >> $dstdir/Scans/UDPresults.lst
	cat $dstdir/Scans/UDPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Masscan completed..."
	echo -e
	
	
	# Weak Credentials on login services
	
	#Let user choose whether to upload their files
	
	echo "Proceeding to Weak Credentials Checks, do you wish to upload your own password or user lists? *Yes/No*"
	
	while [[ $uploadchoice != "yes" && $uploadchoice != "no" ]]; do
	
    echo -n "Your choice : "; read uploadchoice
    
    uploadchoice=$(echo "$uploadchoice" | tr '[:upper:]' '[:lower:]')
    
	done
	
	echo -e
	
	#User choose to upload
	
	if [ $uploadchoice == "yes" ]; then
		
		echo "Please specify if you will upload the USER, PASS or BOTH lists to be use for the credential checks..."
		echo "Default files will be provided if only one options is chosen..."
		
		while [[ $listname != "user" && $listname != "pass" && $listname != "both" ]]; do
		
		echo -n "Your choice : "; read listname
		
		listname=$(echo "$listname" | tr '[:upper:]' '[:lower:]')
		
		done
		
		echo -e
		
		#Upload USER file only
		
		if [[ $listname == "user" ]]; then
		
			echo "Please provide the relative path of the USER file you will be using..."
			read userfile
			echo -e
			
			echo "Retrieving default password list..."
			echo -e
			
			sleep 5
			
			wget -q -O $dstdir/pass.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
			
			passfile=$dstdir/pass.lst
			
			
			echo "Password list saved in $dstdir"
		
		#Upload PASS file only
		
		elif [[ $listname == "pass" ]]; then
		
			echo "Please provide the relative path of the PASS file you will be using..."
			read passfile
			
			echo -e
			echo "Retrieving default user list..."
			echo-e
			
			sleep 5
			
			wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
			
			userfile=$dstdir/user.lst
			
			echo "Password list saved in $dstdir"
			
		#Upload both USER and PASS file
			
		else
		
			echo "Please provide the relative path of the USER file you will be using..."
			read userfile
			echo -e
			echo "Please provide the relative path of the PASS file you will be using..."
			read passfile
			
		fi
		
		#Use default lists instead of uploading
		
	else
		
		echo "Please specify if you would like to use the provided default list of USER, PASS or BOTH..."
		echo "Choosing to use only one of the default list will required user to enter the needed credentials for the other required field..."
		
		while [[ $listname2 != "user" && $listname2 != "pass" && $listname2 != "both" ]]; do
		
		echo -n "Your choice : "; read listname2
		
		listname2=$(echo "$listname2" | tr '[:upper:]' '[:lower:]')
		
		done
		
		echo -e
		
		#Use default USER & PASS file
		
		if [[ $listname2 == "both" ]]; then
		
		echo "Retrieving default user and password list..."
		
		sleep 5
		
		echo -e
		
		wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
		wget -q -O $dstdir/pass.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
		
		userfile=$dstdir/user.lst
		passfile=$dstdir/pass.lst
		
		echo "User and Password list saved in $dstdir"
		
		echo -e
		
		#Use default USER file only
		
		elif [[ $listname2 == "user" ]]; then
		
		echo "Retrieving just the default user list..."
		
		sleep 5
	
		echo -e
		
		wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
		userfile=$dstdir/user.lst
		
		echo "User list saved in $dstdir..."
		echo -e
		echo "Please enter the password credential you would like to use for the check..."
		read passfile
		
		#Use default PASS file only
		
		else
		
		echo "Retrieving just the default password list..."
		
		sleep 5
		
		wget -q -O $dstdir/password.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
		passfile=$dstdir/pass.lst
		
		echo "Password list saved in $dstdir..."
		echo -e
		echo "Please enter the user credential you would like to use for the check..."
		read userfile
		
		fi
		
	fi
	
	#Bruteforcing starts here
	
	echo -e
	mkdir -p $dstdir/Bruteforce
	
	echo "Checking for Weak Credentials..."
	echo -e
	echo "Bruteforcing on SSH... This may take awhile..."
	hydra -L $userfile -P $passfile $ip ssh -t 4 -u 2>/dev/null >> $dstdir/Bruteforce/SSHresults.lst
	cat $dstdir/Bruteforce/SSHresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on RDP... This may take awhile..."
	hydra -L $userfile -P $passfile $ip rdp -t 4 -u 2>/dev/null >> $dstdir/Bruteforce/RDPresults.lst
	cat $dstdir/Bruteforce/RDPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on FTP... This may take awhile..."
	hydra -L $userfile -P $passfile $ip ftp -t 4 -W 10 -u 2>/dev/null >> $dstdir/Bruteforce/FTPresults.lst
	cat $dstdir/Bruteforce/FTPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on Telnet... This may take awhile..."
	nmap -p 23 --script telnet-brute --script-args userdb=$userfile,passdb=$passfile,telnet-brute.timeout=8s $ip >> $dstdir/Bruteforce/TELNETresults.lst
	cat $dstdir/Bruteforce/TELNETresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Results for weak credentials are saved in folder..."
	
	
else
    
    # Run FULL vulnerability scan command here
    
    mkdir -p $dstdir/Scans
    echo "Running Full Vulnerability Scan..."
	echo -e
	echo "Running Nmap Scanning Tool..."
	nmap -sV $ip -p- >> $dstdir/Scans/TCPresults.lst
	cat $dstdir/Scans/TCPresults.lst >> $dstdir/Scans/All_Results.lst
	echo -e
	echo "Running Vulscan on open ports..."
	nmap -sV --script=vulscan/vulscan.nse $ip >> $dstdir/Scans/Vulscanresults.lst
	cat $dstdir/Scans/Vulscanresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Nmap Scan completed..."
	echo -e
	echo "Running Masscan... Permission might be required"
	sudo masscan $ip -pU -p- --rate 500 >> $dstdir/Scans/UDPresults.lst
	cat $dstdir/Scans/UDPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Masscan completed..."
	echo -e
    
    
    # Weak Credentials on login services
    
    
    echo "Proceeding to Weak Credentials Checks, do you wish to upload your own password or user lists? *Yes/No*"
	
	while [[ $uploadchoice != "yes" && $uploadchoice != "no" ]]; do
	
    echo -n "Your choice : "; read uploadchoice
    
    uploadchoice=$(echo "$uploadchoice" | tr '[:upper:]' '[:lower:]')
    
	done
	
	echo -e
	
	#User choose to upload files
	
	if [ $uploadchoice == "yes" ]; then
		
		echo "Please specify if you will upload the USER, PASS or BOTH lists to be use for the credential checks..."
		echo "Default files will be provided if only one options is chosen..."
		
		while [[ $listname != "user" && $listname != "pass" && $listname != "both" ]]; do
		
		echo -n "Your choice : "; read listname
		
		listname=$(echo "$listname" | tr '[:upper:]' '[:lower:]')
		
		done
		
		echo -e
		
		#Upload USER file only
		
		if [[ $listname == "user" ]]; then
		
			echo "Please provide the relative path of the USER file you will be using..."
			read userfile
			
			echo-e
			
			echo "Retrieving default password list..."
			
			sleep 5
			
			wget -q -O $dstdir/pass.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
			
			passfile=$dstdir/pass.lst
			
			echo "Password list saved in $dstdir"
		
		#Upload PASS file only
		
		elif [[ $listname == "pass" ]]; then
		
			echo "Please provide the relative path of the PASS file you will be using..."
			read passfile
			
			echo -e
			
			echo "Retrieving default user list..."
			
			sleep 5
			
			wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
			
			userfile=$dstdir/user.lst
			
			echo "Password list saved in $dstdir"
		
		#Upload USER & PASS file
		
		else
		
			echo "Please provide the relative path of the USER file you will be using..."
			read userfile
			
			echo -e
			
			echo "Please provide the relative path of the PASS file you will be using..."
			read passfile
			
		fi
		
	else
		
		#User choose to use default list
		
		echo "Please specify if you would like to use the provided default list of USER, PASS or BOTH..."
		echo "Choosing to use only one of the default list will required user to enter the needed credentials for the other required field..."
		
		while [[ $listname2 != "user" && $listname2 != "pass" && $listname2 != "both" ]]; do
		
		echo -n "Your choice : "; read listname2
		
		listname2=$(echo "$listname2" | tr '[:upper:]' '[:lower:]')
		
		done
		
		echo -e
		
		#Use default USER & PASS file
		
		if [[ $listname2 == "both" ]]; then
		
		echo "Retrieving default user and password list..."
		
		sleep 5
		
		echo -e
		
		wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
		wget -q -O $dstdir/pass.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
		
		userfile=$dstdir/user.lst
		passfile=$dstdir/pass.lst
		
		echo "User and Password list saved in $dstdir"
		
		echo -e
		
		#Use default USER file only
		
		elif [[ $listname2 == "user" ]]; then
		
		echo "Retrieving just the default user list..."
		
		sleep 5
	
		echo -e
		
		wget -q -O $dstdir/user.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt
		userfile=$dstdir/user.lst
		
		echo "User list saved in $dstdir..."
		echo -e
		echo "Please enter the password credential you would like to use for the check..."
		read passfile
		
		else
		
		#Use default PASS file only
		
		echo "Retrieving just the default password list..."
		
		sleep 5
		
		wget -q -O $dstdir/password.lst https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
		passfile=$dstdir/pass.lst
		
		echo "Password list saved in $dstdir..."
		echo -e
		echo "Please enter the user credential you would like to use for the check..."
		read userfile
		
		fi
		
	fi
	
	#Bruteforcing starts here
	
	echo -e
	
	mkdir -p $dstdir/Bruteforce
	
	echo "Checking for Weak Credentials..."
	echo -e
	echo "Bruteforcing on SSH... This may take awhile..."
	hydra -L $userfile -P $passfile $ip ssh -t 4 -u 2>/dev/null >> $dstdir/Bruteforce/SSHresults.lst
	cat $dstdir/Bruteforce/SSHresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on RDP... This may take awhile..."
	hydra -L $userfile -P $passfile $ip rdp -t 4 -u 2>/dev/null >> $dstdir/Bruteforce/RDPresults.lst
	cat $dstdir/Bruteforce/RDPresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on FTP... This may take awhile..."
	hydra -L $userfile -P $passfile $ip ftp -t 4 -W 10 -u 2>/dev/null >> $dstdir/Bruteforce/FTPresults.lst
	cat $dstdir/Bruteforce/FTPresults.lst >> $dstdir/Scans/All_Results.lst 
	echo "Completed..."
	sleep 5
	echo -e
	echo "Bruteforcing on Telnet... This may take awhile..."
	nmap -p 23 --script telnet-brute --script-args userdb=$userfile,passdb=$passfile,telnet-brute.timeout=8s $ip >> $dstdir/Bruteforce/TELNETresults.lst
	cat $dstdir/Bruteforce/TELNETresults.lst >> $dstdir/Scans/All_Results.lst
	echo "Completed..."
	sleep 5
	echo -e
	echo "Results for weak credentials are saved in folder..."
    
fi

#Search query starts here

echo -e
echo "Do you wish to do a search using the terminal? *Yes/No"
echo "Both options will open the final result file for viewing..."

while [[ $listname3 != "yes" && $listname3 != "no" ]]; do
		
		echo -n "Your choice : "; read listname3
		
		listname3=$(echo "$listname3" | tr '[:upper:]' '[:lower:]')
		
		done

echo -e 

	if [[ $listname3 == "yes" ]]; then
		
		open $dstdir/Scans/All_Results.lst
		
		while true; do

		# Ask the user for input

		read -p "Enter a pattern to grep: " pattern
		echo -e

		# Use grep to find all lines that match the pattern

		grep -E "$pattern" $dstdir/Scans/All_Results.lst
		echo -e

		# Check if the user wants to quit

		read -p "Press Q to quit or any other key to continue: " choice
		echo -e
	
		if [[ "$choice" == "Q" ]] || [[ "$choice" == "q" ]]; then

			break

		fi

		done
	
	else
	
	open $dstdir/Scans/All_Results.lst
	
	fi

#Zip result files

zip -r $dstdir $dstdir

echo -e
echo "All results zipped into zip folder..."
echo -e
echo "End of Vulnerability scans..."