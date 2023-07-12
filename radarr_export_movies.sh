#!/usr/bin/env bash

set -e

which curl &> /dev/null || echo "Please install curl"

function show_usage { 
   echo "Usage:"
   echo -e "\t$0 http://RADARR_HOST:SONARR_PORT [outfile]\n"
   echo "Environment variable RADARR_API_KEY must be set with the RADARR API KEY"
   echo -e "You can get the API KEY from Settings->General\n"
   echo -e "Default outfile is my_radarr.json\n"
   echo "Example:"
   echo -e "\tRADARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 my_awesome_movies.json\n"
}

if [ -f "./.envrc" ]; then 
    . .envrc 
fi

if [ -z "${RADARR_API_KEY}" ]; then 
    echo "Missing RADARR API KEY"
    show_usage;
    exit 1;
fi 

if [ -z "$1" ]; then
   echo "Missing RADARR URL"
   show_usage;
   exit 1
fi

if [ -z "$2" ]; then
    outfile="my_movies.json"
else 
    outfile="$2"
fi 

echo -e "Exporting:\n\tURL is $1, outputfile is $outfile\n"

curlCmd="curl -s -H \"X-Api-Key: $RADARR_API_KEY\" $1/api/v3/movie -o ${outfile}"
eval $curlCmd
