#!/bin/bash
set -e

# WP Migrate Installer
# Usage: curl -fsSL https://wp-migrate.dev/install.sh | bash

REPO="RichardAtCT/wp-migrate-releases"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="wp-migrate"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}==>${NC} $1"
}

warn() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

error() {
    echo -e "${RED}Error:${NC} $1"
    exit 1
}

# Detect OS and architecture
detect_platform() {
    local os arch

    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux*)
            PLATFORM="linux"
            ;;
        Darwin*)
            PLATFORM="macos"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM="windows"
            ;;
        *)
            error "Unsupported operating system: $os"
            ;;
    esac

    case "$arch" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            error "Unsupported architecture: $arch"
            ;;
    esac

    # Only x86_64 prebuilt binaries are published for Linux and Windows.
    # macOS ships a native ARM64 binary (Intel Macs run it via Rosetta 2).
    if [ "$ARCH" = "arm64" ] && [ "$PLATFORM" != "macos" ]; then
        error "No prebuilt $PLATFORM ARM64 binary is available; the $PLATFORM build is x86_64 only.
Please run from source, or contact support@wp-migrate.dev if you need an ARM64 build."
    fi
}

# Abort early (with a clear message) if this system can't run the prebuilt
# Linux binary. The binary is built on Debian 11 (python:3.11-bullseye) and is
# dynamically linked against GNU glibc, so it needs glibc >= 2.31 and will not
# run on musl-based distros (Alpine, etc.) at all. Catching this here replaces
# the cryptic "GLIBC_2.XX not found" loader crash with an actionable message.
# Set WP_MIGRATE_ALLOW_UNSUPPORTED_GLIBC=1 to override the glibc version check.
check_glibc() {
    [ "$PLATFORM" = "linux" ] || return 0

    local required_major=2 required_minor=31 ver major minor ldd_out

    # Probe libc. musl's ldd prints to stderr, so capture both streams.
    ldd_out="$(ldd --version 2>&1 | head -n1)"

    # The binary is glibc-linked; musl systems can't run it regardless of version.
    if printf '%s' "$ldd_out" | grep -qi musl; then
        error "This system uses musl libc (e.g. Alpine Linux), but the prebuilt wp-migrate binary requires GNU glibc >= ${required_major}.${required_minor}.
Please run from source, or contact support@wp-migrate.dev for help."
    fi

    # Best-effort glibc version probe (ldd first, then getconf).
    ver=$(printf '%s' "$ldd_out" | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    if [ -z "$ver" ]; then
        ver=$(getconf GNU_LIBC_VERSION 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    fi

    # If we can't determine the version, don't block the install.
    [ -n "$ver" ] || return 0

    major=${ver%%.*}
    minor=${ver#*.}

    if [ "$major" -lt "$required_major" ] || \
       { [ "$major" -eq "$required_major" ] && [ "$minor" -lt "$required_minor" ]; }; then
        if [ "${WP_MIGRATE_ALLOW_UNSUPPORTED_GLIBC:-}" = "1" ]; then
            warn "Detected glibc $ver (< ${required_major}.${required_minor}); continuing because WP_MIGRATE_ALLOW_UNSUPPORTED_GLIBC=1."
            warn "wp-migrate will likely fail to start with a 'GLIBC_2.XX not found' error."
        else
            error "Detected glibc $ver, but wp-migrate needs glibc >= ${required_major}.${required_minor}.
Your Linux distribution is too old to run the prebuilt binary.
Upgrade your OS, set WP_MIGRATE_ALLOW_UNSUPPORTED_GLIBC=1 to install anyway, or contact support@wp-migrate.dev."
        fi
    fi
}

# Get latest release version
get_latest_version() {
    local version
    version=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        error "Could not determine latest version"
    fi

    echo "$version"
}

# Download and install
install() {
    local version="$1"
    local url binary_name tmp_file

    case "$PLATFORM" in
        linux)
            binary_name="wp-migrate-linux"
            ;;
        macos)
            binary_name="wp-migrate-macos"
            ;;
        windows)
            binary_name="wp-migrate-windows.exe"
            ;;
    esac

    url="https://github.com/$REPO/releases/download/$version/$binary_name"
    tmp_file=$(mktemp)

    info "Downloading wp-migrate $version for $PLATFORM..."
    if ! curl -fsSL "$url" -o "$tmp_file"; then
        error "Failed to download from $url"
    fi

    chmod +x "$tmp_file"

    # Check if we need sudo
    if [ -w "$INSTALL_DIR" ]; then
        mv "$tmp_file" "$INSTALL_DIR/$BINARY_NAME"
    else
        info "Installing to $INSTALL_DIR (requires sudo)..."
        sudo mv "$tmp_file" "$INSTALL_DIR/$BINARY_NAME"
    fi

    # Verify installation
    if command -v wp-migrate &> /dev/null; then
        info "Successfully installed wp-migrate $version"
        echo ""
        wp-migrate --version
        echo ""
        info "Run 'wp-migrate' to start the interactive wizard"
        info "Run 'wp-migrate status' to check license/trial status"
    else
        warn "Installed to $INSTALL_DIR/$BINARY_NAME but 'wp-migrate' not found in PATH"
        warn "Add $INSTALL_DIR to your PATH or run: $INSTALL_DIR/$BINARY_NAME"
    fi
}

main() {
    echo ""
    echo "  WP Migrate Installer"
    echo "  ===================="
    echo ""

    detect_platform
    info "Detected platform: $PLATFORM"

    check_glibc

    local version
    version=$(get_latest_version)

    install "$version"
}

main "$@"
