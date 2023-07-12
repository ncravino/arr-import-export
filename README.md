# Import Export Scripts for Sonarr and Radarr

# Notes 

All scripts will search and source any .envrc file in the execution folder. See .envrc-example for details.

Imports will default for the first language and profile. Edit accordingly.

# Radarr

## Export 

``` 
Usage:
        ./radarr_export_movies.sh http://RADARR_HOST:SONARR_PORT [outfile]

Environment variable RADARR_API_KEY must be set with the RADARR API KEY
You can get the API KEY from Settings->General

Default outfile is my_radarr.json

Example:
        RADARR_API_KEY=MYKEY ./radarr_export_movies.sh http://127.0.0.1:8989 my_awesome_movies.json
```

## Import 

You can use a file similar to the one produced by the export script or a TMBD id.

```
Usage:
        ./radarr_import_movies.sh http://RADARR_HOST:RADARR_PORT [outfile or tmbdId] ROOT_PATH

Environment variable RADARR_API_KEY must be set with the RADARR API KEY
You can get the API KEY from Settings->General

ROOT_PATH \t You can get your Root Path from Settings->Media Management->Root Folders
Examples:
        RADARR_API_KEY=MYKEY ./radarr_import_movies.sh http://127.0.0.1:8989 my_awesome_movies.json /my/radarr/root/path

        RADARR_API_KEY=MYKEY ./radarr_import_movies.sh http://127.0.0.1:8989 tt123456 /my/radarr/root/path
```

# Sonarr 

## Export 

```
Usage:
        ./sonarr_export_series.sh http://SONARR_HOST:SONARR_PORT [outfile]

Environment variable SONARR_API_KEY must be set with the SONARR API KEY
You can get the API KEY from Settings->General

Default outfile is my_series.json

Example:
        SONARR_API_KEY=MYKEY ./export_series.sh http://127.0.0.1:8989 my_awesome_series.json
```

## Import 

You can use a file similar to the one produced by the export script or a TVDB id.

```
Usage:
        ./sonarr_import_series.sh http://SONARR_HOST:SONARR_PORT [outfile or tvdbId] ROOT_PATH

Environment variable SONARR_API_KEY must be set with the SONARR API KEY
You can get the API KEY from Settings->General

ROOT_PATH \t You can get your Root Path from Settings->Media Management->Root Folders
Examples:
        SONARR_API_KEY=MYKEY ./import_series.sh http://127.0.0.1:8989 my_awesome_series.json /my/sonarr/root/path

        SONARR_API_KEY=MYKEY ./import_series.sh http://127.0.0.1:8989 tt123456 /my/sonarr/root/path
```        