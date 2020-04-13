# First, upload the SSH key
resource "digitalocean_ssh_key" "default" {
  name       = var.project_name
  public_key = file(var.ssh_public_key_file)
}

# Then create the VPS for the DB
resource "digitalocean_droplet" "db-vps" {
  image = "ubuntu-18-04-x64"
  name = "${var.project_name}-db"
  region = "fra1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]
}

# Create the Space for backups
resource "digitalocean_spaces_bucket" "db-backups" {
  name = "${var.project_name}-db-backups"
  region = "fra1"
}
