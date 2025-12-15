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
        x86_64|amd64|arm64|aarch64)
            # All supported architectures
            # macOS ARM64 binary works on Intel via Rosetta 2
            ;;
        *)
            error "Unsupported architecture: $arch"
            ;;
    esac
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

    local version
    version=$(get_latest_version)

    install "$version"
}

main "$@"
