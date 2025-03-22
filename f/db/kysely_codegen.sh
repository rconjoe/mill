# shellcheck shell=bash
# the last line of the stdout is the return value
# unless you write json to './result.json' or a string to './result.out'
# shellcheck shell=bash

mkdir kysely

cd kysely

npm init -y
npm install -D kysely-codegen
npm install kysely pg

DATABASE_URL=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/f/db/tonka_railway_pg" | jq -r .)

echo "DATABASE_URL=$DATABASE_URL" > .env

npx kysely-codegen --out-file ./db.d.ts

cat ./db.d.ts

