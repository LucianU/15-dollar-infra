# What is this?
Automation script that gives you:
- one DigitalOcean VPS with Docker installed which you can use for your web app
- one DigitalOcean VPS with:
  - PostgreSQL 11
  - [pgbackrest](https://pgbackrest.org/) for backups
  - only accessible from the web app VPS
- one DigitalOcean Spaces bucket (like AWS S3) that holds the PostgreSQL backups

# Setup

## With Nix
If you have Nix installed, simply run `nix-shell` inside this directory. It will drop you in a shell with all dependencies available.

## Without Nix
* [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Install docker-machine](https://docs.docker.com/machine/install-machine/)
* [Install the DigitalOcean CLI (`doctl`)](https://github.com/digitalocean/doctl#installing-doctl)
* [Install s3cmd](https://s3tools.org/download)