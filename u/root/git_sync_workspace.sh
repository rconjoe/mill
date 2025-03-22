# shellcheck shell=bash

# Set -e to exit immediately if a command exits with a non-zero status
set -e

# arguments of the form X="$I" are parsed as parameters X of type string
token=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/u/root/plentiful_github" | jq -r .)
date=$(date +%Y-%m-%d)

npm i -g windmill-cli

git clone https://rconjoe:$token@github.com/rconjoe/mill.trog.codes.git
cd mill.trog.codes

git config user.name "rconjoe"
git config user.email "root@trog.codes"

wmill workspace add tonka tonka https://mill.trog.codes --token "$WM_TOKEN"

wmill sync pull --yes

date=$(date "+%Y-%m-%d %H:%M:%S")

git add .
git commit -m "sync $date"

# Push changes
git push https://rconjoe:$token@github.com/rconjoe/mill.trog.codes.git master

echo "Script finished."
