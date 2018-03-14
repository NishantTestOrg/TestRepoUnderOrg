#!/bin/bash


#Profile names in AWS credential file. 
#The complete script loops once for each profile

Profiles='ventech ado1 ado2 ado3 ado4 ado5 ado6 ado7 ado8 ado9'


for profile in $Profiles

	do 
	export AWS_PROFILE=$profile
	printf "\n\nListing users, their keys, and respective status for account: `aws sts get-caller-identity --query 'Account' --output text`\n"
	printf "==========================================================\n"
	sleep 3

	#Lists IAM users in the current account being looped
	#Loops once for each user
	for i in `aws iam list-users --query 'Users[*].{UserName:UserName}' --output text`;
	
		do
		printf "\n\nIAM User: $i \n"
		keycount=$(aws iam list-access-keys --user-name $i --query 'AccessKeyMetadata[*].{UserName:UserName}' --output text | wc -l);
		
		if [ "$keycount" == 0 ]; 
			then
			printf "Key does not exist\n\n"

			else
			if [ "$keycount" == 2 ]; then printf "This user has 2 keys:\n\n"; fi
		
			#Loops through each key a user has
			#Maximum possibility is two per user	
			for ((k=0; k<keycount; k++)); 
		
				do
				creationtime=$(aws iam list-access-keys --user-name $i --query 'AccessKeyMetadata['$k'].{Date:CreateDate}' --output text);
				status=$(aws iam list-access-keys --user-name $i --query 'AccessKeyMetadata['$k'].{Status:Status}' --output text | head -1);
				todate=$(date -d $creationtime +%s 2>/dev/null)
				
				#fromdate is epoch time
				fromdate=$(date -d `date -u +"%Y-%m-%dT%H:%M:%SZ"` +%s)
				timediff=$((fromdate-todate))
				timediffindays=$((timediff/86400))

				if [ $timediff -gt 1728000 ]; 
					then
					printf "=======KEY IS OLD=====. Current age is $timediffindays days\nWARNING!! Please inform the user before it is deactivated/deleted"
					printf "\nCurrent Status is: $status\n\n"

					else
        			printf "Key is new and hence still valid. Current age is $timediffindays days"
					printf "\nCurrent Status: $status\n\n"	
				fi

				done
		fi
		
		done;
	done;




