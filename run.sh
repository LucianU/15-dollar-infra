#!/usr/bin/env bash

[ -z "$DOTOKEN" ] && echo "You need to set the env variable DOTOKEN with your DigitalOcean API Token"
[ -z "$DO_SPACES_KEY" ] && echo "You need to set the env variable DO_SPACES_KEY with your DigitalOcean Spaces Key"
[ -z "$DO_SPACES_KEY_SECRET" ] && echo "You need to set the env variable DO_SPACES_KEY_SECRET with your DigitalOcean Spaces Key Secret"

if [ -z "$1" ]
then
  echo "Usage:"
  echo "  $0 [app-name]"
  echo "  example: $0 hacker-news"
  exit 1
fi

export WEB_APP_NAME="$1"

./setup_web_vps.sh

./setup_db_vps.sh