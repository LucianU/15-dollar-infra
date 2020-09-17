# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
    vb.memory = "512"
    # This prevents vagrant from creating an "ubuntu-[version-name]-[version-number]-cloudimg-console.log" file
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/provision_db_vps.yml"
    ansible.compatibility_mode = "2.0"
    ansible.extra_vars = {
      login_user: "lucian",
      postgres_user_password: ENV['POSTGRES_USER_PASSWORD'],
      postgres_backups_repo_cipher_pass: ENV['POSTGRES_BACKUPS_REPO_CIPHER_PASS'],
      postgres_backups_repo_key: ENV['PGBACK_DO_SPACES_KEY'],
      postgres_backups_repo_key_secret: ENV['PGBACK_DO_SPACES_KEY_SECRET'],
      postgres_backups_repo_region: "fra1",
      postgres_backups_repo_endpoint: "fra1.digitaloceanspaces.com",
      postgres_backups_repo_bucket_name: "test-pgbackrest",
      postgres_whitelist_ip: ENV['WEB_APP_VPS_IP']
    }
  end
end
