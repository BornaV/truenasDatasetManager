#!/bin/bash

#to use this script the you need to provide host, api_token and pool, optionaly my_secret if you would like to use decryption pasword for your master password


#to create secret encrypted using base64
#echo $MY_SECRET|base64 --decode|openssl enc -aes-256-cbc -a -d -salt -pbkdf2

host="" # ip:port  ie 10.0.0.200:500
API_TOKEN="" #api token from truenas
pool="" #example "pool_name/dataset_name"

export MY_SECRET="" #save here the encrypted password to use password_prottected secret

user_input(){
read -p "$1 [l/u/Q]"
if [[ $REPLY =~ ^[Qq]$ ]]
then
 exit
fi
}

if [ -z "$API_TOKEN" ]
then
	echo "API_TOKEN is missing"
	exit
fi
if [ -z "$1" ]
  then
	user_input "Do you want to lock or unlock the dataset"
  else
    REPLY=$1
fi
if [[ $REPLY =~ ^[Uu]$ ]]
then
	if [ -z "$MY_SECRET" ]
	then
      echo "please enter your pool secret: "
      read MY_SECRET
	else
      MY_SECRET=$(echo -n $MY_SECRET|base64 --decode|openssl enc -aes-256-cbc -a -d -salt -pbkdf2)
	fi

	echo $MY_SECRET
	curl "https://$host/api/v2.0/pool/dataset/unlock" -k -X POST -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer 1-$API_TOKEN" -d "{\"id\": \"$pool\",\"unlock_options\": {\"key_file\": false,\"recursive\": false,\"toggle_attachments\": true,\"datasets\": [{\"name\" : \"$pool\" , \"passphrase\" : \"$MY_SECRET\"}]}}"
elif [[ $REPLY =~ ^[Ll]$ ]]
then
	curl "https://$host/api/v2.0/pool/dataset/lock" -k -X POST -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer 1-$API_TOKEN" -d "{\"id\": \"$pool\"}"
else
    exit
fi




