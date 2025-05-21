#!/bin/bash

# Pamildori Linux Installer
# This script installs Pamildori on Linux systems

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

# Define variables
APP_NAME="pamildori"
INSTALL_DIR="/opt/$APP_NAME"
BIN_LINK="/usr/bin/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
ICON_DIR="/usr/share/icons/hicolor/256x256/apps"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/../../build/linux/x64/release/bundle"

# Check if build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "Error: Build directory not found at $BUILD_DIR"
  echo "Please run 'flutter build linux --release' first"
  exit 1
fi

echo "Installing Pamildori..."

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICON_DIR"

# Copy application files
cp -r "$BUILD_DIR"/* "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/$APP_NAME"

# Create symlink in /usr/bin
ln -sf "$INSTALL_DIR/$APP_NAME" "$BIN_LINK"

# Copy desktop file
cp "$SCRIPT_DIR/$APP_NAME.desktop" "$DESKTOP_FILE"

# Copy icon
cp "$SCRIPT_DIR/../../assets/images/logo.png" "$ICON_DIR/$APP_NAME.png"

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
  update-desktop-database
fi

echo "Installation complete. You can now launch Pamildori from your application menu." 