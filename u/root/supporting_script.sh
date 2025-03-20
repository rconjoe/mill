# shellcheck shell=bash

# Set -e to exit immediately if a command exits with a non-zero status
set -e

# arguments of the form X="$I" are parsed as parameters X of type string
token=$(curl -s -H "Authorization: Bearer $WM_TOKEN" \
  "$BASE_INTERNAL_URL/api/w/$WM_WORKSPACE/variables/get_value/u/root/plentiful_github" | jq -r .)
date=$(date +%Y-%m-%d)

# Install windmill-cli globally
npm i -g windmill-cli

# Clone the repository
git clone https://rconjoe:$token@github.com/rconjoe/mill.trog.codes.git
cd mill.trog.codes

# Configure Git user name and email
git config user.name "rconjoe"
git config user.email "root@trog.codes"

# Add Windmill workspace
wmill workspace add tonka tonka https://mill.trog.codes --token "$WM_TOKEN"

# Sync pull
wmill sync pull --yes

# Check for changes before committing
if ! git diff --quiet --exit-code; then
  # Get the current date
  date=$(date "+%Y-%m-%d %H:%M:%S")

  # Commit changes
  git commit -am "sync $date"

  # Push changes
  git push https://rconjoe:$token@github.com/rconjoe/mill.trog.codes.git master
  echo "Changes committed and pushed successfully."
else
  echo "No changes to commit."
fi

echo "Script finished."
