# shellcheck shell=bash

set -e

# setup vars
gh_token=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/u/root/plentiful_github" | jq -r .)
database_url=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/f/db/tonka_railway_pg" | jq -r .)
date=$(date "+%Y-%m-%d %H:%M:%S")

# need all this installed globally on the worker bc why make another package.json
npm i -g windmill-cli kysely kysely-codegen pg

# clone the mill repo
git clone https://rconjoe:$gh_token@github.com/rconjoe/mill.git
cd mill
git config user.name "rconjoe"
git config user.email "root@trog.codes"

# setup local mill workspace
wmill workspace add tonka tonka https://mill.trog.codes --token "$WM_TOKEN"
wmill sync pull --yes 

# run codegen
echo "DATABASE_URL=$database_url" > .env
cat .env
kysely-codegen --out-file ./f/db/types.ts 

# push changes to remote workspace
wmill sync push --yes 

# sync git
git add .
git commit -m "db model update sync $date"
git push https://rconjoe:$gh_token@github.com/rconjoe/mill.git master


