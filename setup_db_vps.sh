#!/usr/bin/env bash

DB_VPS_SSH_PRIVATE_KEY="$HOME/.ssh/$WEB_APP_NAME"_rsa
TERRAFORM_SETUP_DIR="terraform"

# Generate SSH key for the DB vps
[ ! -f "$DB_VPS_SSH_PRIVATE_KEY" ] && ssh-keygen -f "$DB_VPS_SSH_PRIVATE_KEY"  -t rsa -b 4096 -N "" -C "$WEB_APP_NAME-db"

# Add the SSH key to the SSH Agent
ssh-add "$DB_VPS_SSH_PRIVATE_KEY"

# Initialize Terraform, if necessary
[ ! -f "$PWD/$TERRAFORM_SETUP_DIR/terraform.tfstate" ] && terraform init terraform/

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

# Ge the IP and the region of the VPS
DB_VPS_IP=$(terraform output -state="$TERRAFORM_SETUP_DIR"/terraform.tfstate db_vps_ip)
DB_VPS_REGION=$(terraform output -state=$TERRAFORM_SETUP_DIR/terraform.tfstate db_backups_bucket_region)

# Provision the PostgreSQL VPS
ansible-playbook ansible/provision.yml \
  --ssh-common-args="-o ProxyCommand=\"ssh -W %h:%p -q root@$WEB_APP_VPS_IP\"" \
  --ssh-common-args='-o UserKnownHostsFile=/dev/null -o "StrictHostKeyChecking=no"' \
  --user=root \
  --private-key="${DB_VPS_SSH_PRIVATE_KEY}" \
  --extra-vars="web_app_user=${WEB_APP_NAME}" \
  --extra-vars="web_app_ip=${WEB_APP_VPS_IP}" \
  --extra-vars="postgres_user_password=md5$(echo -n "$POSTGRES_USER_PASSWORD$WEB_APP_NAME" | md5sum | awk '{print $1}')" \
  --extra-vars="postgres_backups_repo_bucket_name=$(terraform output -state=$TERRAFORM_SETUP_DIR/terraform.tfstate db_backups_bucket_name)" \
  --extra-vars="postgres_backups_repo_region=${DB_VPS_REGION}" \
  --extra-vars="postgres_backups_repo_endpoint=${DB_VPS_REGION}.digitaloceanspaces.com" \
  --extra-vars="postgres_backups_repo_cipher_pass=${POSTGRES_BACKUPS_REPO_CIPHER_PASS}" \
  --extra-vars="postgres_backups_repo_key=${PGBACK_DO_SPACES_KEY}" \
  --extra-vars="postgres_backups_repo_key_secret=${PGBACK_DO_SPACES_KEY_SECRET}" \
  --inventory="${DB_VPS_IP},"  # Without the comma, Ansible takes this as a file path