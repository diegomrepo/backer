#!/bin/bash
set -e #set -o errexit

sudo echo "Gained sudo access" || exit 1


# Function to open a URL in the default web browser
open_url() {
  xdg-open "$1" &>/dev/null
}

# Check if .github_token file exists
token_file=".github_token"

if [ -f "$token_file" ]; then
  # If the token file exists, read the token from the file
  github_token=$(cat "$token_file")
  echo "GitHub token found in $token_file"
else
  # If the token file doesn't exist, prompt the user to generate a new token
  # Prompt the user to click the link
  echo "Please click the following link to generate a GitHub token:"
  echo "https://github.com/settings/tokens/new"

  # Open the URL in the default web browser
  open_url "https://github.com/settings/tokens/new"

  # Wait for the user to paste the token
  read -p "Paste your GitHub token here: " github_token

  # Save the token to the .github_token file for future use
  echo "$github_token" > "$token_file"
  echo "GitHub token saved to $token_file"
fi

# Update system package manager
sudo apt update

# Install Git
sudo apt install -y git

# Install pip
sudo apt install -y python3-pip

# Install Ansible via pip
sudo pip3 install ansible

# Clone or pull the GitHub repository containing the Ansible playbook
if [ -d "my-config" ]; then
  # Directory exists, perform a Git pull
  cd my-config
  git pull origin main
else
  # Directory does not exist, perform a Git clone
  git clone https://$github_token@github.com/diegomrepo/my-config.git
  cd my-config
fi

# Download backup.yml from the specified URL
backup_url="https://raw.githubusercontent.com/diegomrepo/backuper/main/backup.yml"
curl -fsSL -o backup.yml "$backup_url"
echo "backup.yml downloaded successfully from $backup_url"

# Install required Ansible roles
#ansible-galaxy install -r requirements.yml

# Run the Ansible playbook to backup dot files and configs and upload them to GitHub
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook backup.yml
