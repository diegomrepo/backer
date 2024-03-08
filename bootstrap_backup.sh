#!/bin/bash
set -e #set -o errexit

# Gain sudo access
if sudo echo "Gained sudo access"; then
  echo "Sudo access granted"
else
  echo "Failed to gain sudo access"
  exit 1
fi

# Function to open a URL in the default web browser
open_url() {
  xdg-open "$1" &>/dev/null
}

# Function to prompt the user for input
prompt_user() {
  read -p "$1: " input
  echo "$input"
}

# Check if arguments are provided, otherwise prompt the user
if [ $# -eq 3 ]; then
  git_name="$1"
  git_email="$2"
  backup_repo="$3"
else
  # Prompt the user for Git user name
  git_name=$(prompt_user "Enter your Github user name")

  # Prompt the user for Git email
  git_email=$(prompt_user "Enter your Github email")

  # Prompt the user for the backup repository
  backup_repo=$(prompt_user "Enter the backup repository (in the format 'username/repo')")
fi


# Set the backuper directory
BINDIR="$HOME/bin"
if mkdir -p "$BINDIR"; then
  echo "Backuper directory created at $BINDIR"
else
  echo "Failed to create backuper directory"
  exit 1
fi

# Set the XDG_DATA_HOME directory and create the backuper folder
xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
backuper_data_dir="$xdg_data_home/backuper"
if mkdir -p "$backuper_data_dir"; then
  echo "Backuper data directory created at $backuper_data_dir"
else
  echo "Failed to create backuper data directory"
  exit 1
fi

# Define the destination path for backup.yml
playbookfile="$backuper_data_dir/backup.yml"

# Define the destination path for backuper executable
backuper_exe="$BINDIR/backuper"

# Check if .github_token file exists
token_file="$HOME/.github_token"
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
  if echo "$github_token" > "$token_file" && chmod 0400 "$token_file"; then
    echo "GitHub token saved to $token_file with 0400 permissions"
  else
    echo "Failed to save GitHub token to $token_file"
    exit 1
  fi
fi

# Update system package manager
if sudo apt update; then
  echo "System package manager updated successfully"
else
  echo "Failed to update system package manager"
  exit 1
fi

# Install Git
if sudo apt install -y git; then
  echo "Git installed successfully"
else
  echo "Failed to install Git"
  exit 1
fi

# Install pip
if sudo apt install -y python3-pip; then
  echo "Pip installed successfully"
else
  echo "Failed to install Pip"
  exit 1
fi

# Install Ansible via pip
if sudo pip3 install ansible; then
  echo "Ansible installed successfully"
else
  echo "Failed to install Ansible"
  exit 1
fi
repo_tmp="$HOME/tmp/my-config"
# Clone or pull the GitHub repository containing the Ansible playbook
if [ -d "$repo_tmp" ]; then
  echo Directory exists, perform a Git pull
  if cd "$repo_tmp" && git pull origin main; then
    echo "GitHub repository pulled successfully"
  else
    echo "Failed to pull GitHub repository"
    exit 1
  fi
else
  echo Directory does not exist, perform a Git clone
  if mkdir -p $HOME/tmp && cd $HOME/tmp && git clone https://$github_token@github.com/diegomrepo/my-config.git && cd "$repo_tmp"; then
    echo "GitHub repository cloned successfully"
  else
    echo "Failed to clone GitHub repository"
    exit 1
  fi
fi

# Download backup.yml from the specified URL
backup_url="https://raw.githubusercontent.com/diegomrepo/backuper/main/backup.yml"
if curl -fsSL -o "$playbookfile" "$backup_url"; then
  echo "backup.yml downloaded successfully to $playbookfile"
else
  echo "Failed to download backup.yml"
  exit 1
fi

# Create the backuper executable file in ~/bin
# echo "ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook ${playbookfile} ${@}" > "$backuper_exe"
# if chmod +x "$backuper_exe"; then
#   echo "Backuper executable created at $backuper_exe"
# else
#   echo "Failed to create backuper executable"
#   exit 1
# fi

# Install required Ansible roles
#ansible-galaxy install -r requirements.yml

# Run the Ansible playbook to backup dot files and configs and upload them to GitHub
# if ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook "$playbookfile"; then
#   echo "Ansible playbook executed successfully"
# else
#   echo "Failed to execute Ansible playbook"
#   exit 1
# fi

# Run the Ansible playbook to backup dot files and configs and upload them to GitHub
if ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook "$playbookfile" --extra-vars "git_name='$git_name' git_email='$git_email' backup_repo='$backup_repo'"; then
  echo "Ansible playbook executed successfully"
else
  echo "Failed to execute Ansible playbook"
  exit 1
fi
