#!/usr/bin/env bash

set -e

which curl &> /dev/null || echo "Please install curl"

function show_usage { 
   echo "Usage:"
   echo -e "\t$0 http://SONARR_HOST:SONARR_PORT [outfile]\n"
   echo "Environment variable SONARR_API_KEY must be set with the SONARR API KEY"
   echo -e "You can get the API KEY from Settings->General\n"
   echo -e "Default outfile is my_series.json\n"
   echo "Example:"
   echo -e "\tSONARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 my_awesome_series.json\n"
}

if [ -f "./.envrc" ]; then 
    . .envrc 
fi

if [ -z "${SONARR_API_KEY}" ]; then 
    echo "Missing SONARR API KEY"
    show_usage;
    exit 1;
fi 

if [ -z "$1" ]; then
   echo "Missing SONARR URL"
   show_usage;
   exit 1
fi

if [ -z "$2" ]; then
    outfile="my_series.json"
else 
    outfile="$2"
fi 

echo -e "Exporting:\n\tURL is $1, outputfile is $outfile\n"

curlCmd="curl -s -H \"X-Api-Key: $SONARR_API_KEY\" $1/api/v3/series -o ${outfile}"
eval $curlCmd