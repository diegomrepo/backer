## Configuration Backup Utility
It provides Bash scripts and an Ansible playbook for backing up dot files and configurations to a private GitHub repository.

### Getting Started:
Before executing the script, make sure you have created a GitHub repository (recommended to set up as private). During execution, you will be prompted to provide the committer's email and name.

### Requirements:
The utility is designed for Debian-based systems. If you're operating within constrained version or environment, the presence of both `sudo` and `curl` is required.

### One-Step Setup:
You can initiate the backup process with this single command:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backer/main/bootstrap.sh)"
```

### Convenient Wrapper:
After setup, you can use the backer wrapper installed in ~/bin to run the backup process easily.
```bash
~/bin/backer
```

### Directory Contents:
- `bootstrap.sh` Script for setting up essential tools.
- `backup.yml` Ansible playbook automating the backup process for dot files and configurations.
