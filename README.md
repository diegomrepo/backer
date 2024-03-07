# My Config Backup

This repository contains scripts and an Ansible playbook for backing up dot files and configurations to a GitHub repository.

## Usage

### 1. GitHub Token

Before running the scripts, obtain a GitHub token by following these steps:

1. Click the following link to generate a GitHub token: [Generate GitHub Token](https://github.com/settings/tokens/new)
2. Copy the generated token.
3. Paste the token when prompted.

### 2. Bootstrap Script

Run the bootstrap script to set up the necessary tools:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backuper/main/bootstrap.sh)"
```
### 3. Ansible Playbook
Alternatively, use the Ansible playbook for a more automated backup process:

```bash
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook backup.yml
```
## Directory Structure
- `bootstrap.sh` Script to set up the necessary tools.
- `backup.yml` Ansible playbook for automated dot file backup.
