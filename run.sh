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

WEB_APP_NAME="$1"
DB_VPS_SSH_PRIVATE_KEY="$HOME/.ssh/$WEB_APP_NAME"_rsa

# Create the web app VPS. We need its IP to whitelist it with PostgreSQL
docker-machine create --driver digitalocean \
  --digitalocean-access-token "$DOTOKEN" \
  --digitalocean-image "ubuntu-18-04-x64" \
  --digitalocean-region "fra1" \
  --digitalocean-size "s-1vcpu-1gb" \
  "$WEB_APP_NAME"

# Add the SSH key to the SSH Agent
ssh-add "$HOME/.docker/machine/machines/$WEB_APP_NAME/id_rsa"

# Get the IP of the web app VPS
WEB_APP_VPS_IP=$(docker-machine ip "$WEB_APP_NAME")

# Generate SSH key for this app, if it doesn't exist
[ ! -f "$DB_VPS_SSH_PRIVATE_KEY" ] && ssh-keygen -f "$DB_VPS_SSH_PRIVATE_KEY"  -t rsa -b 4096 -N "" -C "$WEB_APP_NAME-db"

# Add the SSH key to the SSH Agent
ssh-add "$DB_VPS_SSH_PRIVATE_KEY"

# Initialize Terraform, if necessary
[ ! -f "$PWD/terraform.tfstate" ] && terraform init

# This is needed because Terraform won't find the state file, if it was just created
sleep 5

# Create the Digital Ocean Spaces bucket and the PostgreSQL VPS
terraform apply \
  -var "project_name=$WEB_APP_NAME" \
  -var "ssh_public_key_file=$DB_VPS_SSH_PRIVATE_KEY.pub" \
  -var "do_token=$DOTOKEN" \
  -var "do_spaces_key=$DO_SPACES_KEY" \
  -var "do_spaces_key_secret=$DO_SPACES_KEY_SECRET" \
  terraform/

# Ge the IP of the PostgreSQL VPS
DB_VPS_IP=$(terraform output db_vps_ip)

# TO DO
# Figure out how to connect to the PostgreSQL VPS, since it's on a private network
# Connect to the APP VPS and copy the SSH private key
# Copy over or clone this repo
# Install ansible
# Run the command below
# Using the APP VPS to provision the PostgreSQL VPS doesn't work, because I don't know how to install Ansible
# I will look at connecting to the PostgreSQL VPS through App VPS

# Provision the PostgreSQL VPS
POSTGRES_USER_PASSWORD=$(openssl rand -base64 32)

ansible-playbook ansible/provision.yml \
  --ssh-common-args="-o ProxyCommand=\"ssh -W %h:%p -q root@$WEB_APP_VPS_IP\"" \
  --ssh-common-args='-o UserKnownHostsFile=/dev/null -o "StrictHostKeyChecking=no"' \
  --user=root \
  --private-key="${DB_VPS_SSH_PRIVATE_KEY}" \
  --extra-vars="web_app_user=${WEB_APP_NAME} web_app_ip=${WEB_APP_VPS_IP}" \
  --extra-vars="postgres_user_password=md5$(echo -n "$POSTGRES_USER_PASSWORD$WEB_APP_NAME" | md5sum | awk '{print $1}')" \
  --extra-vars="postgres_cluster_name=${WEB_APP_NAME}" \
  --extra-vars="postgres_backups_repo_bucket_name=$(terraform output db_backups_bucket_name)" \
  --extra-vars="postgres_backups_repo_region=$(terraform output db_backups_bucket_region)" \
  --extra-vars="postgres_backups_repo_endpoint=digitaloceanspaces.com" \
  --extra-vars="postgres_backups_repo_cipher_pass=$(openssl rand -base64 48)" \
  --extra-vars="postgres_backups_repo_key=${PGBACK_DO_SPACES_KEY}" \
  --extra-vars="postgres_backups_repo_key_secret=${PGBACK_DO_SPACES_KEY_SECRET}" \
  --inventory="${DB_VPS_IP},"  # Without the comma, Ansible takes this as a file path

ansible-playbook ansible/provision.yml \
  --ssh-common-args="-o ProxyCommand=\"ssh -W %h:%p -q root@134.122.85.215\"" \
  --ssh-common-args="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" \
  --user=root \
  --private-key="~/.ssh/move_rsa" \
  --extra-vars="web_app_user=move web_app_ip=142.93.167.153" \
  --extra-vars="postgres_cluster_name=move" \
  --extra-vars="postgres_backups_repo_bucket_name=move-db-backups" \
  --extra-vars="postgres_backups_repo_region=fra1" \
  --extra-vars="postgres_backups_repo_endpoint=digitaloceanspaces.com" \
  --extra-vars="postgres_backups_repo_key=${DO_SPACES_KEY}" \
  --extra-vars="postgres_backups_repo_key_secret=${DO_SPACES_KEY_SECRET}" \
  --inventory="134.122.85.215,"
