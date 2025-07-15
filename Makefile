SCRIPTS_DIR := ./scripts

.PHONY: help stow-backup stow-restore stow-add-new stow-deploy stow-status stow-install-deps setup-new

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
	@echo "  help           - Show this help message"
	@echo ""

# 🗃️ Stow Configuration Management

stow-backup:
	@bash $(SCRIPTS_DIR)/stow-backup.sh

stow-restore:
	@bash $(SCRIPTS_DIR)/stow-restore.sh

stow-add-new:
	@bash $(SCRIPTS_DIR)/stow-add-new.sh

stow-deploy:
	@bash $(SCRIPTS_DIR)/stow-deploy.sh

stow-status:
	@bash $(SCRIPTS_DIR)/stow-status.sh

stow-install-deps:
	@bash $(SCRIPTS_DIR)/stow-install-deps.sh

# 💻 New Computer Setup

setup-new:
	@bash $(SCRIPTS_DIR)/setup-new-environment.sh