#!/bin/bash
set -e    # exit on error of any command error
#set -x   # uncommend when debugging

# Function to open a URL in the default web browser
open_url() {
  if [ -n "$DISPLAY" ]; then
    xdg-open "$1" &>/dev/null
  else
    echo "Not in a graphical session. Skipping browser opening."
  fi
}

# Function to prompt the user for input
prompt_user() {
  read -p "$1: " input
  echo "$input"
}

# Function to check if the Linux distribution is Debian
is_debian() {
  [ -e /etc/os-release ] && source /etc/os-release && [ "$ID" == "debian" ]
}

# Function to install Ansible based on the Linux distribution
install_ansible() {
  if is_debian; then
    # Install Ansible using apt on Debian
    if sudo apt install -y ansible-core; then
      echo "Ansible installed successfully"
    else
      echo "Failed to install Ansible"
      exit 1
    fi
  else
    # Install pip
    if sudo apt install -y python3-pip; then
      echo "Pip installed successfully"
    else
      echo "Failed to install Pip"
      exit 1
    fi
    # Install Ansible using pip for other distributions
    if sudo pip3 install ansible; then
      echo "Ansible installed successfully"
    else
      echo "Failed to install Ansible"
      exit 1
    fi
  fi
}

# Function to verify if a Git repository exists
verify_git_repo() {
  local repo_url="$1"
  local github_repo_url="https://github.com/$repo_url"
  local github_token=$(cat $HOME/.github_token)

  # Use the GitHub token in the URL for authentication
  if git ls-remote "https://$github_token@github.com/$repo_url" &>/dev/null; then
    echo "GitHub repository exists"
  else
    echo "GitHub repository does not exist or token is not valid"
    exit 1
  fi
}

# Gain sudo access
if sudo echo "Gained sudo access"; then
  echo "Sudo access granted"
else
  echo "Failed to gain sudo access"
  exit 1
fi
# Update system package manager
if sudo apt update; then
  echo "System package manager updated successfully"
else
  echo "Failed to update system package manager"
  exit 1
fi

# Install Git
if sudo apt install -y git rsync; then
  echo "git/rsync installed successfully"
else
  echo "Failed to install Git"
  exit 1
fi

# Check if arguments are provided, otherwise prompt the user
if [ $# -eq 3 ]; then
  git_name="$1"
  git_email="$2"
  backup_repo="$3"
else
  # Prompt the user for Git user name
  git_name=$(prompt_user "Enter your Github commit name (e.g. John Doe)")

  # Prompt the user for Git email
  git_email=$(prompt_user "Enter your Github email")

  # Prompt the user for the backup repository
  backup_repo=$(prompt_user "Enter the backup repository (in the format 'username/repo')")
fi

# Set the backer directory
BINDIR="$HOME/bin"
if mkdir -p "$BINDIR"; then
  echo " directory created at $BINDIR"
else
  echo "Failed to create  directory"
  exit 1
fi

# Define the destination path for  executable
backer_exe="$BINDIR/backer"

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

verify_git_repo "$backup_repo"

# Set the XDG_DATA_HOME directory and create the backer folder
xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
backer_data_dir="$xdg_data_home/backer"
if mkdir -p "$backer_data_dir"; then
  echo "backer data directory created at $backer_data_dir"
else
  echo "Failed to create backer data directory"
  exit 1
fi

# Define the destination path for backup.yml
playbookfile="$backer_data_dir/backup.yml"

# Install Ansible based on the Linux distribution
install_ansible

repo_tmp="$HOME/tmp/${backup_repo##*/}"

# Function to check and pull the 'main' branch
check_and_pull_main() {
  if git rev-parse --verify main >/dev/null 2>&1; then
    if git pull origin main; then
      echo "GitHub repository pulled successfully, main branch in-place"
    else
      echo "Failed to pull GitHub repository"
      exit 1
    fi
  else
    echo "Main branch doesn't exist, performing initialization"
    git config user.email "$git_email"
    git config user.name "$git_name"
    if git checkout -b main && git commit --allow-empty -m "Initial commit" && git push -u origin main; then
      echo "Main branch initialized and pushed successfully"
    else
      echo "Failed to initialize main branch and push"
      exit 1
    fi
  fi
}

# Check if the repository exists and is not empty
if [ -d "$repo_tmp/.git" ] && [ "$(ls -A $repo_tmp)" ]; then
  # Navigate into the repository directory
  if cd "$repo_tmp"; then
    check_and_pull_main
  else
    echo "Failed to navigate into the repository directory"
    exit 1
  fi
else
  # If the repository directory doesn't exist or is empty, perform a fresh clone
  echo "Directory does not exist or is empty, performing a Git clone"
  if mkdir -p "$HOME/tmp" && cd "$HOME/tmp" && git clone "https://${github_token}@github.com/$backup_repo"; then
    echo "GitHub repository cloned successfully"
    # Navigate into the repository directory
    if cd "${backup_repo##*/}"; then
      check_and_pull_main
    else
      echo "Failed to navigate into the cloned repository directory"
      exit 1
    fi
  else
    echo "Failed to clone GitHub repository"
    exit 1
  fi
fi

# Download backup.yml from the specified URL
backup_url="https://raw.githubusercontent.com/diegomrepo/backer/main/backup.yml"
if curl --connect-timeout 15 -fsSL -o "$playbookfile" "$backup_url"; then
  echo "backup.yml downloaded successfully to $playbookfile"
else
  echo "Failed to download backup.yml"
  exit 1
fi

# Run the Ansible playbook to backup dot files and configs and upload them to GitHub
if ansible-playbook "$playbookfile" --extra-vars "cur_home='$HOME' git_name='$git_name' git_email='$git_email' backup_repo='$backup_repo'"; then
  echo "Ansible playbook executed successfully"
else
  echo "Failed to execute Ansible playbook"
  exit 1
fi

# Create the backer executable file in ~/bin
echo "ansible-playbook ${playbookfile} --extra-vars 'cur_home=\"$HOME\" git_name=\"$git_name\" git_email=\"$git_email\" backup_repo=\"$backup_repo\"'" > "$backer_exe"
if chmod +x "$backer_exe"; then
  echo "backer executable created at $backer_exe"
else
  echo "Failed to create backer executable"
  exit 1
fi

echo Next time to backup, just execute ~/bin/backer
