## Project - Penetration Testing

**Objective**

1.1 Get from the user a network to scan

- user shld have freedom to choose what network they want u to scan
    - u shldnt hard code it into your code

**1.3.2 Full: include Nmap Scripting Engine (NSE), weak passwords, and vulnerability analysis**

- NSE can be used for vuln assessments
    - pls **DO NOT use the —script vuln** nse category because it is way too long and not realistic
    - use a script that goes by the name of vuln___ that will give u a list of cves based on open services
    - nmap default scripts is not vuln analysis but just enumeration
- NOTE: full scan also includes basic scan

1.4 Make sure the input is valid.

- script shld have input validation
- can be as simple as making sure 1.1 inputs look like ip addresses with their cidr

2.1.1 Have a built-in password.lst to check for weak passwords.

- if the user doesnt specify a wordlist to use, u have a default builtin list to use automatically
- if submit own list, use rel path instead of abs path to ref it

2.1.2 Allow the user to supply their own password list.

- give the user the choice to choose whether to use their own list

4.3 Allow the user to search inside the results.

- recurring function to ask for search input and then use grep
- or implement external file editor into your script

4.4 Allow to save all results into a Zip file.

- shld ask if want to zip all output contents ideally with the dir name provided in 1.2

5. Creativity

- if u use extra tools, please ensure to install all required dependencies before the actual code
    - eg. in python this will likely be a requirements.txt
