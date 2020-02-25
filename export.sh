#!/bin/bash

# Default configuration (override these using environment variables passed to script):
DEFAULT_GIT_URL=""
DEFAULT_OVERLEAF_PROJECT=""
DEFAULT_SESSION=""

set -e

# Easy layered configuration mechanism. Fallback to above DEFAULTs if no environment variable is set:
fallback() {
    if [[ -z "$1" ]]; then
        echo "$2" 
    else
        echo "$1"
    fi
}
GIT_URL=$(fallback "$GIT_URL" "$DEFAULT_GIT_URL")
OVERLEAF_PROJECT=$(fallback "$OVERLEAF_PROJECT" "$DEFAULT_OVERLEAF_PROJECT")
SESSION=$(fallback "$SESSION" "$DEFAULT_SESSION")

AUTO=false
if [[ "$1" =~ ^.*auto.*$ ]]; then
    echo "Automatic sync enabled."
    AUTO=true
fi

validate() {
    if [[ "${GIT_URL}" =~ ^.+git$ ]]; then
        echo "GIT_URL: ${GIT_URL}"
    else
        echo "Please pass a valid GIT_URL (ending with '.git')"
        exit 1
    fi
    if [[ "${OVERLEAF_PROJECT}" =~ ^[a-f0-9]{24}$ ]]; then
        echo "OVERLEAF_PROJECT: ${OVERLEAF_PROJECT}"
    else
        echo "Please pass a valid OVERLEAF_PROJECT (ID consisting of 24 hex chars)"
        exit 2
    fi
    if [[ "${SESSION}" =~ ^s%[a-zA-Z0-9\.]{12,}$ ]]; then
        echo "SESSION: ${SESSION}"
    else
        echo "Please pass a valid SESSION (starting with 's%')"
        exit 3
    fi
}

validate

sync() {
    curl "https://www.overleaf.com/project/${OVERLEAF_PROJECT}/download/zip" -H "origin: https://www.overleaf.com" \
        -K base.cmdline -H "cookie: overleaf_session2=${SESSION}" --compressed > overleaf-project.zip
    if [[ $(stat --printf="%s" overleaf-project.zip) -lt 100 ]]; then
        echo "Warning: Downloaded response (archive) is smaller than excepted."
        if [[ $(cat overleaf-project.zip) == *"Forbidden"* ]]; then
            echo ">> Access seems to be forbidden. This is likely due to an invalid session."
            echo ">> It is recommended to update your session as described in the README!"
            exit 10
        fi
    fi

    unzip -o overleaf-project.zip -d overleaf-project/

    if [[ -d github-project/ ]]; then
        echo "No need to clone: Directory github-project already exists."
        echo ">> If you want to change your GitHub repo, call './wipe.sh' before executing this script."
    else
        git clone "${GIT_URL}" github-project/
    fi

    pushd github-project > /dev/null
    git pull
    rm -rf *
    cp -rf ../overleaf-project/* .
    git add .
    git commit -m ":twisted_rightwards_arrows: Sync with Overleaf project"
    git push
    popd > /dev/null
}

if [[ $AUTO == true ]]; then
    updates=""
    while true; do
        new_updates=$(curl "https://www.overleaf.com/project/${OVERLEAF_PROJECT}/updates?min_count=5" -K base.cmdline -H "referer: https://www.overleaf.com/project/${OVERLEAF_PROJECT}" -H "cookie: overleaf_session2=${SESSION}" --compressed --silent)
        if [[ "$updates" == "$new_updates" ]]; then
            echo "No new updates."
        else
            echo "New update(s) found:"
            echo "${new_updates}"
            sync
        fi
        echo "Sleeping 60 seconds before re-fetching updates..."
        updates=$new_updates
        sleep 60
    done
else
    sync
fi