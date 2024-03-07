# My Config Backup

This repository contains scripts and an Ansible playbook for backing up dot files and configurations to a private GitHub repository.

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backuper/main/bootstrap.sh)"
```
### Utility
Alternatively, after the first-time use, the Ansible playbook can be invoked anytime by using a wrapper called `backuper` installed in `~/bin`

```bash
~/bin/backuper
```
## Directory Structure
- `bootstrap.sh` Script to set up the necessary tools.
- `backup.yml` Ansible playbook for automated dot file backup.
