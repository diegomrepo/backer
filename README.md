# My Config Backup

This repository contains scripts and an Ansible playbook for backing up dot files and configurations to a private GitHub repository.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backuper/main/bootstrap.sh)"
```
### Utility
Alternatively, after 1st time use, the Ansible playbook (inside a wrapper called `backuper`) will be installed inside `~/bin`

```bash
~/bin/backuper
```
## Directory Structure
- `bootstrap.sh` Script to set up the necessary tools.
- `backup.yml` Ansible playbook for automated dot file backup.
