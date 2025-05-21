#!/bin/bash

# Pamildori Linux Uninstaller
# This script removes Pamildori from Linux systems

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
ICON_FILE="/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

echo "Uninstalling Pamildori..."

# Remove files
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "- Removed installation directory"
fi

if [ -L "$BIN_LINK" ]; then
  rm "$BIN_LINK"
  echo "- Removed binary link"
fi

if [ -f "$DESKTOP_FILE" ]; then
  rm "$DESKTOP_FILE"
  echo "- Removed desktop file"
fi

if [ -f "$ICON_FILE" ]; then
  rm "$ICON_FILE"
  echo "- Removed icon"
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
  gtk-update-icon-cache -f -t /usr/share/icons/hicolor
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
  update-desktop-database
fi

echo "Uninstallation complete. Pamildori has been removed from your system." 