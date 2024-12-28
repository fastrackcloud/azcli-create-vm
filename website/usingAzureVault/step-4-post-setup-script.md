# Step 4: Post-Setup Script (Custom Script Extension)
```bash
#!/bin/bash

# Create Post-Setup Cloud-Init File
cat <<EOF > post-setup-cloud-init.txt
#cloud-config
runcmd:
  - echo "Fetching GitHub token from Key Vault..."
  - TOKEN=\$(az keyvault secret show --name GitHubToken --vault-name Vault122820241605 --query value -o tsv)
  - if [ -z "\$TOKEN" ]; then echo "Failed to retrieve GitHub token."; exit 1; fi
  - echo "Cloning GitHub repository..."
  - git clone https://\$TOKEN@github.com/<username>/<repository>.git /tmp/website-automation
  - cp -r /tmp/website-automation/* /var/www/html/
  - mv /var/www/html/htaccess /var/www/html/.htaccess
  - sed -i '19iDirectoryIndex index.php /html/index.php' /etc/apache2/sites-available/000-default.conf
  - echo "Restarting Apache..."
  - systemctl restart apache2
EOF
