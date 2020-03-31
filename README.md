# What is this?
Automation script that gives you:
- one DigitalOcean VPS with Docker installed which you can use for your web app
- one DigitalOcean VPS with:
  - PostgreSQL 11
  - [pgbackrest](https://pgbackrest.org/) for backups
  - only accessible from the web app VPS
- one DigitalOcean Spaces bucket (like AWS S3) that holds the PostgreSQL backups

This setup provisions a DigitalOcean droplet for your web app and another droplet for your PostgreSQL database.
It also enables backups for the database. For that purpose it uses `pgbackrest` and it saves the backups on a DigitalOcean Spaces bucket.
