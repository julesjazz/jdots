# ✨ jdots — Secure Dotfiles Management

> **USE AT YOUR OWN RISK**  
> My attempt at creating a dotfile manager for my personal workflow using an LLM.
---

## 🚀 Quick Start

```sh
# One-time: install dependencies
make stow-install-deps

# Backup your dotfiles (runs a security audit first)
make stow-backup

# Restore or deploy configs
make stow-restore   # Restore from backup
make stow-deploy    # Deploy to your system

# Security audit (standalone)
make security-audit
```

---

## 🗂️ Structure

```
~/jdots/
├── Makefile           # Command interface
├── scripts/           # All backup/restore/security scripts
│   ├── stow-backup.sh
│   ├── stow-restore.sh
│   ├── stow-deploy.sh
│   ├── stow-clean.sh
│   ├── stow-status.sh
│   ├── stow-add-new.sh
│   ├── stow-install-deps.sh
│   └── security-audit.sh
├── stowfiles/
│   ├── config/        # Backed up ~/.config/*
│   └── home/          # Backed up ~/.zshrc, ~/.gitconfig, ~/.bashrc, ~/.asdfrc
└── .gitignore         # Excludes secrets, keys, backups, etc.
```

---

## 🔒 Security
- **Automatic audit**: Every backup runs a security scan on only the files to be backed up (not your whole home directory)
- **Excludes**: History, cache, backup, and sensitive files are never backed up
- **Hidden files**: Dotfiles are expected and confirmed as safe before backup

---

## 🛠️ Commands
- `make stow-backup` — Secure backup (with audit)
- `make stow-restore` — Restore configs from backup
- `make stow-deploy` — Deploy configs to your system
- `make stow-clean` — Remove stow symlinks
- `make stow-status` — Show stow package status
- `make stow-add-new` — Add new directories to stow packages
- `make stow-install-deps` — Install GNU Stow
- `make security-audit` — Standalone security check

---

## 🎯 Philosophy
- **Security first**: Never risk leaking secrets
- **Minimal, portable, auditable**
- **No symlinks or config edits in $HOME during backup**
- **All logic in `~/jdots/scripts/`**

---
