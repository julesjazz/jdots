SCRIPTS_DIR := ./scripts

.PHONY: help stow-backup stow-restore stow-add-new stow-deploy stow-status stow-install-deps setup-new security-audit

# TODO: 
# expand on system packages
# scripts to restore/backup each OS/manager to stowfiles/system_packages/[brew, apt, dnf]
# only restore the one that matches the current OS/manager

# Default target
help:
	@echo "jdots management commands:"
	@echo ""
	@echo "Stow Configuration Management:"
	@echo "  stow-backup    - Backup .config files to stow packages"
	@echo "  stow-restore   - Restore .config files from stow packages"
	@echo "  stow-add-new   - Add new .config directories to stow packages"
	@echo "  stow-deploy    - Deploy stow packages to ~/.config"

	@echo "  stow-status    - Show status of stow packages"
	@echo "  stow-install-deps - Install dependencies for dotfiles"
	@echo ""
	@echo "New Computer Setup:"
	@echo "  setup-new        - Complete setup for new computer (brew + stow)"
	@echo ""
	@echo "Security:"
	@echo "  security-audit   - Run security audit on repository"
	@echo ""
	@echo "  help           - Show this help message"
	@echo ""

# Stow Configuration Management
stow-backup:
	@echo "📦 Backing up .config files to stow packages..."
	@$(SCRIPTS_DIR)/stow-backup.sh

stow-restore:
	@echo "🔄 Restoring .config files from stow packages..."
	@$(SCRIPTS_DIR)/stow-restore.sh

stow-add-new:
	@echo "➕ Adding new .config directories to stow packages..."
	@$(SCRIPTS_DIR)/stow-add-new.sh

stow-deploy:
	@echo "🚀 Deploying stow packages to ~/.config..."
	@$(SCRIPTS_DIR)/stow-deploy.sh
	
stow-status:
	@echo "📊 Showing status of stow packages..."
	@$(SCRIPTS_DIR)/stow-status.sh

stow-install-deps:
	@echo "🔧 Installing dependencies for dotfiles..."
	@$(SCRIPTS_DIR)/stow-install-deps.sh

# New Computer Setup
setup-new:
	@echo "🚀 Setting up new environment..."
	@$(SCRIPTS_DIR)/setup-new-environment.sh

# Security
security-audit:
	@echo "🔒 Running security audit..."
	@$(SCRIPTS_DIR)/security-audit.sh