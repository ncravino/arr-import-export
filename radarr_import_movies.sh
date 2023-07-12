#!/usr/bin/env bash

set -e

which curl &> /dev/null || echo "Please install curl"
which grep &> /dev/null || echo "Please install grep"
which tr &> /dev/null || echo "Please install tr"
which jq &> /dev/null || echo "Please install jq"
which xargs &> /dev/null || echo "Please install xargs"

function show_usage { 
   echo "Usage:"
   echo -e "\t$0 http://RADARR_HOST:RADARR_PORT [outfile or tmbdid] ROOT_PATH\n"
   echo "Environment variable RADARR_API_KEY must be set with the RADARR API KEY"
   echo -e "You can get the API KEY from Settings->General\n"
   echo "ROOT_PATH \t You can get your Root Path from Settings->Media Management->Root Folders"
   echo "Examples:"
   echo -e "\tRADARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 my_awesome_movies.json /my/radarr/root/path\n"
   echo -e "\tRADARR_API_KEY="MYKEY" $0 http://127.0.0.1:8989 tt123456 /my/radarr/root/path\n"
}

if [ -f "./.envrc" ]; then 
    . .envrc 
fi

if [ -z "${RADARR_API_KEY}" ]; then 
    echo "[ERROR] Missing RADARR API KEY environment variable!"
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

RADARR_URL=$1
ROOT_FOLDER_PATH=$3

function import_one {
    if [ -z "$1" ]; then 
        echo "Unexpected invocation without parameters"
        exit 1
    fi 

    TMDBID=$1
    
    addOptions="{\"addOptions\":{\"monitor\":\"movieOnly\",\"searchForMovie\":true,\"ignoreEpisodesWithFiles\":false,\"ignoreEpisodesWithoutFiles\":false},\"rootFolderPath\":\"$ROOT_FOLDER_PATH\"}"

    movieData=$(curl -s "${RADARR_URL}/api/v3/movie/lookup?term=tmdb%3A${TMDBID}" -H "X-Api-Key: $RADARR_API_KEY")

    qualityProfileId=$( curl -s "${RADARR_URL}/api/v3/qualityprofile/" -H "X-Api-Key: $RADARR_API_KEY" | jq ".[0] | .id")

    moviePath="$ROOT_FOLDER_PATH/$(echo $movieData | jq -r ".[0] .folder")"

    moviePayload=$(echo $movieData | jq ".[0] + $addOptions + {\"monitored\":true,\"qualityProfileId\":$qualityProfileId,\"folderName\":\"$moviePath\",\"path\":\"$moviePath\"}")
    
    curl -s "${RADARR_URL}/api/v3/movie" -H 'Content-Type: application/json' -H "X-Api-Key: $RADARR_API_KEY" --data-raw "$moviePayload" 2>&1 >> radarr_import_log.txt

}

if [ -f "$2" ]; then
    echo "Using file $2" | tee radarr_import_log.txt

    for tid in $(cat "$2" | jq ".[] | .tmdbId"); do 
        echo "\n$tid LOG START" >> radarr_import_log.txt
        import_one $tid
        echo "\n$tid LOG END" >> radarr_import_log.txt
    done
else 
   echo "Using imdbId $2" | tee radarr_import_log.txt
   import_one $2
fi

echo "done, check radarr_import_log.txt"

