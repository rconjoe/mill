# shellcheck shell=bash

# Set -e to exit immediately if a command exits with a non-zero status
set -e

# arguments of the form X="$I" are parsed as parameters X of type string
gh_token=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/u/root/plentiful_github" | jq -r .)

date=$(date +%Y-%m-%d)

npm i -g windmill-cli kysely kysely-codegen pg

# clone the mill repo
git clone https://rconjoe:$gh_token@github.com/rconjoe/mill.git
cd mill
git config user.name "rconjoe"
git config user.email "root@trog.codes"

wmill workspace add tonka tonka https://mill.trog.codes --token "$WM_TOKEN"

wmill sync pull --yes 

database_url=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/f/db/tonka_railway_pg" | jq -r .)
echo "DATABASE_URL=$database_url" > .env
cat .env

kysely-codegen --out-file ./f/db/types.ts 

wmill sync push --yes 

git add .
git commit -m "db model update sync $datef"

