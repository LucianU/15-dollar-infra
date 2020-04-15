# What is this?
Automation script that gives you:
- one DigitalOcean VPS with Docker installed which you can use for your web app
- one DigitalOcean VPS with:
  - PostgreSQL 11
  - [pgbackrest](https://pgbackrest.org/) for backups
  - only accessible from the web app VPS
- one DigitalOcean Spaces bucket (like AWS S3) that holds the PostgreSQL backups

It uses Ansible, docker-machine and Terraform.

# Setup
## With Nix
If you have Nix installed, simply run `nix-shell` inside this directory. It will drop you in a shell with all dependencies available.

## Without Nix
* [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Install docker-machine](https://docs.docker.com/machine/install-machine/)
* [Install Terraform](https://www.terraform.io/downloads.html)
* Set the following environment variables:
  * `DOTOKEN`: DigitalOcean API Token
  * `DO_SPACES_KEY`: DigitalOcean Spaces API Key
  * `DO_SPACES_KEY_SECRET`: DigitalOcean Spaces API Key Secret
  * `POSTGRES_USER_PASSWORD`: You can generate it with `openssl rand -base64 32`
  * `POSTGRES_BACKUPS_REPO_CIPHER_PASS`: The password for the backups repo. You can use the same method as above to generate it.
* Use the `run.sh` script:

  `./run.sh [app-name]`