#!/usr/bin/env bash

set -e

which curl &> /dev/null || echo "Please install curl"
which grep &> /dev/null || echo "Please install grep"
which tr &> /dev/null || echo "Please install tr"
which jq &> /dev/null || echo "Please install jq"
which xargs &> /dev/null || echo "Please install xargs"

function show_usage { 
   echo "Usage:"
   echo -e "\t$0 http://SONARR_HOST:SONARR_PORT [outfile or tvbdid] ROOT_PATH\n"
   echo "Environment variable SONARR_API_KEY must be set with the SONARR API KEY"
   echo -e "You can get the API KEY from Settings->General\n"
   echo "ROOT_PATH \t You can get your Root Path from Settings->Media Management->Root Folders"
   echo "Examples:"
   echo -e "\tSONARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 my_awesome_series.json /my/sonarr/root/path\n"
   echo -e "\tSONARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 tt123456 /my/sonarr/root/path\n"
}

if [ -f "./.envrc" ]; then 
    . .envrc 
fi

if [ -z "${SONARR_API_KEY}" ]; then 
    echo "[ERROR] Missing SONARR API KEY environment variable!"
    show_usage;
    exit 1;
fi 

if [ -z "$2" ]; then
   echo "[ERROR] Missing File or imdbId!"
   show_usage;
   exit 1
fi

if [ -z "$3" ]; then
   echo "[ERROR] Missing Root Path!"
   show_usage;
   exit 1
fi

SONARR_URL=$1
ROOT_FOLDER_PATH=$3

function import_one {
    if [ -z "$1" ]; then 
        echo "Unexpected invocation without parameters"
        exit 1
    fi 

    TVDBID=$1
    
    addOptions="{\"addOptions\":{\"monitor\":\"all\",\"searchForMissingEpisodes\":true,\"searchForCutoffUnmetEpisodes\":false},\"rootFolderPath\":\"$ROOT_FOLDER_PATH\"}"

    seriesData=$(curl -s "${SONARR_URL}/api/v3/series/lookup?term=tvdb%3A${TVDBID}" -H "X-Api-Key: $SONARR_API_KEY")

    qualityProfileId=$( curl -s "${SONARR_URL}/api/v3/qualityprofile/" -H "X-Api-Key: $SONARR_API_KEY" | jq ".[0] | .id")
    languageProfileId=$( curl -s "${SONARR_URL}/api/v3/languageprofile/" -H "X-Api-Key: $SONARR_API_KEY" | jq ".[0] | .id")

    seriesPayload=$(echo $seriesData | jq ".[0] + $addOptions + {\"id\":0,\"monitored\":true,\"qualityProfileId\":$qualityProfileId, \"languageProfileId\":$languageProfileId, \"seasonFolder\":true}")
    
    curl -s "${SONARR_URL}/api/v3/series" -H 'Content-Type: application/json' -H "X-Api-Key: $SONARR_API_KEY" --data-raw "$seriesPayload" 2>&1 >> sonarr_import_log.txt

}

if [ -f "$2" ]; then
    echo "Using file $2" | tee sonarr_import_log.txt

    for tid in $(cat "$2" | jq ".[] | .tvdbId"); do 
        echo "\n$tid LOG START" >> sonarr_import_log.txt
        import_one $tid
        echo "\n$tid LOG END" >> sonarr_import_log.txt
    done
else 
   echo "Using imdbId $2" | tee sonarr_import_log.txt
   import_one $2
fi

echo "done, check log.txt"


