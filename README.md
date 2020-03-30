# What is this?
Automation for your web app.

This setup provisions a DigitalOcean droplet for your web app and another droplet for your PostgreSQL database.
It also enables backups for the database. For that purpose it uses `pgbackrest` and it saves the backups on a DigitalOcean Spaces bucket.
