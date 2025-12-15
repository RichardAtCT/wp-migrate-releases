# WP Migrate

A CLI tool for migrating WordPress sites between servers using only FTP/SFTP access. No SSH required.

## Quick Install

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/RichardAtCT/wp-migrate-releases/main/install.sh | bash
```

### Windows
Download `wp-migrate-windows.exe` from the [latest release](https://github.com/RichardAtCT/wp-migrate-releases/releases/latest) and add to your PATH.

## Manual Install

### Linux
```bash
curl -L https://github.com/RichardAtCT/wp-migrate-releases/releases/latest/download/wp-migrate-linux -o wp-migrate
chmod +x wp-migrate
sudo mv wp-migrate /usr/local/bin/
```

### macOS
```bash
curl -L https://github.com/RichardAtCT/wp-migrate-releases/releases/latest/download/wp-migrate-macos -o wp-migrate
chmod +x wp-migrate
sudo mv wp-migrate /usr/local/bin/
```

## Features

- Works with shared hosting (no SSH needed)
- FTP, FTPS, and SFTP support  
- Database export/import with URL replacement
- Handles WordPress serialized data correctly
- Interactive wizard or config file mode
- Pre-DNS-cutover site verification

## Quick Start

```bash
# Start interactive wizard
wp-migrate

# Check license/trial status
wp-migrate status

# Activate license
wp-migrate activate WPMIG-XXXX-XXXX-XXXX-XXXX
```

## Trial

WP Migrate includes **3 free migrations**. After that, a license is required.

**Purchase:** https://wp-migrate.dev/buy

## Support

For issues and feature requests: support@wp-migrate.dev
