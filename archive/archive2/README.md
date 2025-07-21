

✅ Tomorrow TODO

🛠️ Fix & Restore
- Fix your broken git config
- Review .gitconfig, ensure identity and signing settings are accurate.
- Restore from backup if needed or manually reconfigure.
- Backup new setup
- Archive your current jdots working state into a new dated directory:
    - `cp -r ~/jdots ~/jdots-archive-$(date +%Y-%m-%d)`
- Recover reusable logic
- Identify key scripts/modules from:
    - scripts/
    - ASDF workflows
    - redaction/restore system
    - Move into reusable Ansible roles or tagged Make targets.

⸻

💾 Improve Backups
- List GUI/core apps that can’t be backed up with dotfiles
- iterm2, ghostty, any GUI preferences, etc.
- Identify if they support:
- Config export (plist, json, etc.)
- CLI sync tools
- Start a new script: scripts/backup-gui.sh
- Design hooks for backup-in-dotfiles flow
- Add a step to your backup routine that:
- Calls asdf-backup.sh
- Exports iTerm2 profile
- Compresses config folders if needed

⸻

⚙️ Begin Ansible Migration
- Scaffold Ansible project
- Create folder layout (inventories/, roles/, playbooks/, etc.)
- Bootstrap setup.yml with:
- dotfiles role
- asdf role
- shell role (zsh/bash/starship)
- Integrate into existing Makefile
- Add make provision or make ansible-bootstrap:

```
provision:
	ansible-playbook -i inventories/local/hosts.yml playbooks/setup.yml --ask-become-pass
```
- Reuse existing vars (from `profile.env`)
- Convert to group_vars/all.yml or inject with vars_files
- Start small, test headless/CLI config first

---
potential iterm2 backup script

```sh
#!/bin/bash

# Specify your custom preferences folder
ITerm2_CONFIG_DIR="$HOME/dotfiles/iterm2-config"

# Ensure the directory exists
mkdir -p "$ITerm2_CONFIG_DIR"

# Save current iTerm2 preferences to the custom folder
defaults export com.googlecode.iterm2 "$ITerm2_CONFIG_DIR/com.googlecode.iterm2.plist"

echo "iTerm2 configuration backed up to $ITerm2_CONFIG_DIR"
```