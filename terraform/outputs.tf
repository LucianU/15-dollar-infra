output "db_vps_ip" {
  value = digitalocean_droplet.db-vps.ipv4_address_private
}

output "db_backups_bucket_name" {
  value = digitalocean_spaces_bucket.db-backups.name
}

output "db_backups_bucket_region" {
  value = digitalocean_spaces_bucket.db-backups.region
}
