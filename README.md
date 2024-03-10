## Configuration Backup Utility
Welcome to the Configuration Backup Utility repository. This collection includes meticulously crafted scripts and an Ansible playbook designed for seamlessly backing up your essential dot files and configurations. The backup process is directed towards a private GitHub repository of your choice, ensuring a secure and organized storage solution.

### Getting Started
To initiate the configuration backup, follow the straightforward steps below:

Ensure you have a GitHub repository created in advance to serve as your dedicated backup space.
Have your GitHub repository email and commit name ready, as these will be used for committing the backup in your name.

### One-Step Setup
Execute the following command in your terminal to kickstart the backup process:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/diegomrepo/backuper/main/bootstrap.sh)"
```
### Convenient Wrapper
After the initial setup, you can effortlessly run the Ansible playbook anytime using the backuper wrapper. This utility is conveniently installed in ~/bin. Execute the following command to run the backup:

```bash
~/bin/backuper
```

### Repository Structure
- `bootstrap.sh` Script for setting up essential tools.
- `backup.yml` Ansible playbook automating the backup process for dot files and configurations.
