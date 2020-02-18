#!/bin/bash

GIT_URL="CONFIGURE ME"

set -e

if [[ "${GIT_URL}" =~ ^.+git$ ]]; then
    echo "GIT_URL: ${GIT_URL}"
else
    echo "Please enter a valid GIT_URL (ending with .git)"
    exit 1
fi

./your-copied-curl.sh > overleaf-project.zip

unzip -o overleaf-project.zip -d overleaf-project/
if [[ -d github-project/ ]]; then
    echo "No need to clone: Directory github-project already exists."
    echo "If you want to change your GitHub repo, call './wipe.sh' before executing this script."
else
    git clone "${GIT_URL}" github-project/
fi

cd github-project
git pull
cp -rf ../overleaf-project/* .
git add .
git commit -m ":twisted_rightwards_arrows: Sync with overleaf project"
git push
