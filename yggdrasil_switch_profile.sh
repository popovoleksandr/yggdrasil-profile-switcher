#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if necessary commands are installed
missing_packages=()
for cmd in jq sed; do
  if ! command_exists "$cmd"; then
    missing_packages+=("$cmd")
  fi
done

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command_exists "launchctl"; then
    missing_packages+=("launchctl (part of macOS, required to manage services)")
  fi
else
  if ! command_exists "systemctl" && [ -f /etc/debian_version ]; then
    missing_packages+=("systemctl (part of systemd, required to manage services on Linux)")
  fi
fi

if ! command_exists "yggdrasil"; then
  missing_packages+=("yggdrasil")
fi

if [ ${#missing_packages[@]} -ne 0 ]; then
  echo "The following required packages are missing:"
  for pkg in "${missing_packages[@]}"; do
    echo "  - $pkg"
  done
  exit 1
fi

# Check if the configuration file path and profile name are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <config_file_path> <profile_name>"
  exit 1
fi

# Get the configuration file path and profile name from the arguments
MAIN_CONFIG_FILE="$1"
PROFILE_NAME="$2"

# Check if the main configuration JSON file exists
if [ ! -f "$MAIN_CONFIG_FILE" ]; then
  echo "Main config file '$MAIN_CONFIG_FILE' does not exist."
  exit 1
fi

# Extract the config file path from the main configuration JSON file
CONFIG_FILE=$(jq -r '.ConfigFilePath' "$MAIN_CONFIG_FILE")

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file '$CONFIG_FILE' does not exist."
  exit 1
fi

# Extract the peers for the selected profile
PEERS=$(jq -r --arg PROFILE_NAME "$PROFILE_NAME" '.Profiles[] | select(.name == $PROFILE_NAME) | .peers | join("\\\n    ")' "$MAIN_CONFIG_FILE")

if [ -z "$PEERS" ]; then
  echo "Profile '$PROFILE_NAME' not found in the config file."
  exit 1
fi

# Create a backup of the yggdrasil config file
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Update the Peers section in the yggdrasil config file
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sudo sed -i.bak "/Peers: \[/,/]/c\\
  Peers: [\\
    $PEERS\\
  ]
  " "$CONFIG_FILE"
else
  # Linux
  sudo sed -i "/Peers: \[/,/]/c\\
  Peers: [\\
    $PEERS\\
  ]
  " "$CONFIG_FILE"
fi

# Restart the yggdrasil service
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sudo launchctl unload /Library/LaunchDaemons/yggdrasil.plist
  if [ $? -ne 0 ]; then
    echo "Failed to unload the yggdrasil service"
    exit 1
  fi

  sudo launchctl load /Library/LaunchDaemons/yggdrasil.plist
  if [ $? -ne 0 ]; then
    echo "Failed to load the yggdrasil service"
    exit 1
  fi
else
  # Linux
  if command_exists "systemctl"; then
    sudo systemctl restart yggdrasil
    if [ $? -ne 0 ]; then
      echo "Failed to restart the yggdrasil service"
      exit 1
    fi
  else
    echo "systemctl not found. Ensure you have systemd installed, or manually restart the yggdrasil service."
    exit 1
  fi
fi

echo "Switched to profile '$PROFILE_NAME' and restarted yggdrasil service."
