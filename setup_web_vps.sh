#!/usr/bin/env bash

# Create the web app VPS. We need its IP to whitelist it with PostgreSQL
docker-machine create --driver digitalocean \
  --digitalocean-access-token "$DOTOKEN" \
  --digitalocean-image "ubuntu-18-04-x64" \
  --digitalocean-region "fra1" \
  --digitalocean-size "s-1vcpu-1gb" \
  "$WEB_APP_NAME"

# Add the SSH key to the SSH Agent
ssh-add "$HOME/.docker/machine/machines/$WEB_APP_NAME/id_rsa"
