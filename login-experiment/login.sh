#!/bin/bash

echo "Getting CSRF token..."
csrf_token=$(curl 'https://www.overleaf.com/login' -K csrf-token.cmdline 2>&1 | grep -oP '(?<=_csrf" type="hidden" value=").*?(?=">)')
echo "CSRF: ${csrf_token}"

YOUR_PW=""
YOUR_USERNAME=""
echo "Attempting login..."
curl 'https://www.overleaf.com/login' -K login.cmdline \
    --data-binary "{\"_csrf\":\"${csrf_token}\",\"email\":\"${YOUR_USERNAME}\",\"password\":\"${YOUR_PASSWORD}\"}"
