## Configuration Backup Utility:
It provides Bash scripts and an Ansible playbook for backing up dot files and configurations to a private GitHub repository.

### Getting Started:
Before executing the script, make sure you have created a GitHub repository (recommended to set up as private). During execution, you will be prompted to provide the committer's email and name.

### Requirements:
The utility is designed for Debian-based systems. For users operating within constrained versions or environments, the presence of both `sudo` and `curl` is required.

### One-Step Setup:
Users can initiate the backup process with a single command provided in the section.
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backer/main/bootstrap.sh)"
```

### Convenient Wrapper:
After setup, users can use the backer wrapper installed in ~/bin to run the backup process easily.
```bash
~/bin/backer
```

### Repository Structure
- `bootstrap.sh` Script for setting up essential tools.
- `backup.yml` Ansible playbook automating the backup process for dot files and configurations.
