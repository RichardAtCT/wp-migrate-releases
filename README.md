# WP Migrate

A CLI tool for migrating WordPress sites between any servers. Works with SSH, SFTP, FTPS, or FTP — automatically uses the fastest method available.

## Quick Install

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/RichardAtCT/wp-migrate-releases/main/install.sh | bash
```

*macOS: Native ARM64 binary for Apple Silicon. Intel Macs run via Rosetta 2.*

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

- Works with any hosting (shared, VPS, dedicated)
- Auto-detects SSH/WP-CLI for fastest transfers
- Falls back to FTP/SFTP when SSH unavailable
- rsync for 4-10x faster file transfers (with SSH)
- Database export/import with URL replacement
- Handles WordPress serialized data correctly
- Interactive wizard or config file mode
- Pre-DNS-cutover site verification
- ✅ Multisite network migrations (network → network) — auto-detected
- ✅ Import a standalone site into an existing multisite network as a new subsite

## Quick Start

```bash
# Start interactive wizard
wp-migrate

# Check license/trial status
wp-migrate status

# Activate license (use key from purchase email)
wp-migrate activate xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Multisite

WP-Migrate supports WordPress multisite two ways:

**Migrate an entire network (network → network).** Auto-detected from the source
`wp-config.php` — just run `wp-migrate migrate -c config.yaml`. Network constants
are regenerated for the new host and every subsite's URLs are rewritten.

**Import a standalone site into an existing network.** Add `mode: multisite-import`
and a `multisite_import` block to your config, then:

```bash
wp-migrate import-to-network -c config.yaml --dry-run   # preview
wp-migrate import-to-network -c config.yaml             # run
```

WP-Migrate registers a new subsite, imports the source's tables under a new `wp_{N}_*` prefix, merges users (matching by login/email), relocates media to `wp-content/uploads/sites/{N}/`, and rewrites URLs — leaving the rest of the network untouched. The network's `wp-config.php` and database are preserved.

## Trial

WP Migrate includes **3 free migrations**. After that, a license is required.

**Purchase:** https://wp-migrate.dev/buy

## Support

For issues and feature requests: support@wp-migrate.dev
