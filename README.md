# Redmine IP Fence Plugin

## Features
This plugin implements network isolation for Redmine attachments, controlling access permissions based on upload and download IP addresses.

## Installation
1. Copy the plugin directory to Redmine's `plugins/` directory
2. Run database migrations in the Redmine directory:
   ```bash
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```
3. Restart the Redmine service

## Configuration
1. Log in to Redmine as an administrator
2. Go to "Administration" → "Plugins" → "Redmine IP Fence Plugin"
3. Configure internal network IP ranges (one IP range per line, wildcard * is supported)

## Verification
1. Upload a file from an internal IP - it should be marked as sensitive
2. Attempt to download a sensitive file from an external IP - access should be denied
3. Download a file from an internal IP - access should be allowed
