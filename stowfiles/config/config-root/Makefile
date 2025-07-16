SCRIPTS_DIR := ./scripts

.PHONY: help asdf-update-global asdf-backup asdf-restore install-zsh-plugins pm-clean pm-install pm-sync-to-master pm-sync-from-master pm-sync-diff maintenance maint setup-new

# Default target
help:
	@echo "jdots management commands:"
	@echo ""
	@echo "ASDF Configuration"
	@echo "  asdf-update-global"
	@echo "  asdf-backup"
	@echo "  asdf-restore"
	@echo ""
	@echo "ZSH Configuration:"
	@echo "  install-zsh-plugins - Install ZSH plugins to ~/.config/zsh/plugins"
	@echo ""
	@echo "Package Manager Management:"
	@echo "  pm-clean      - Comprehensive package manager cleanup and maintenance"
	@echo "  pm-backup-clean - Clean up backup files (prompts for confirmation)"
	@echo "  pm-backup-clean-dry - Clean up backup files (dry run - no changes)"
	@echo "  pm-backup-clean-verbose - Clean up backup files (detailed output)"
	@echo "  pm-install   - Install packages from package lists"
	@echo "  pm-install-dry - Install packages (dry run - no changes)"
	@echo "  pm-install-verbose - Install packages (detailed output)"
	@echo "  pm-sync-to-master   - Sync computer package list to master"
	@echo "  pm-sync-from-master - Sync master package list to computer"
	@echo "  pm-sync-diff        - Show differences between package lists"
	@echo ""
	@echo "System Maintenance:"
	@echo "  maintenance    - (alias: maint) Full system maintenance (security + brew cleanup + stow backup)"
	@echo "  setup-new      - Complete setup for new computer (sync brew lists + install packages)"
	@echo ""
	@echo "  help           - Show this help message"
	@echo ""

# ASDF Configuration
asdf-update-global:
	@echo "🔄 Updating asdf tools to latest LTS..."
	@$(SCRIPTS_DIR)/asdf-update-lts.sh
	@echo "📌 Setting globally to latest installed versions..."
	@$(SCRIPTS_DIR)/asdf-set-latest.sh
	@echo "🗃️  Backing up asdf config..."
	@$(SCRIPTS_DIR)/asdf-backup.sh
	@echo "✅ Done: asdf tools updated, set, and backed up!"
	
asdf-restore:
	@echo "♻️  Restoring asdf tools and plugins..."
	@$(SCRIPTS_DIR)/asdf-restore.sh

asdf-backup:
	@echo "📦 Running asdf backup..."
	@$(SCRIPTS_DIR)/asdf-backup.sh

# ZSH Configuration
install-zsh-plugins:
	@echo "🔌 Installing ZSH plugins..."
	@$(SCRIPTS_DIR)/install-zsh-plugins.sh

# Package Manager Management
pm-clean:
	@echo "🧹 Running comprehensive package manager cleanup..."
	@$(SCRIPTS_DIR)/pm-manager.sh clean

pm-backup-clean:
	@echo "🗑️  Running backup file cleanup..."
	@$(SCRIPTS_DIR)/pm-manager.sh backup-clean

pm-backup-clean-dry:
	@echo "🗑️  Running backup file cleanup (dry run)..."
	@$(SCRIPTS_DIR)/pm-manager.sh backup-clean --dry-run

pm-backup-clean-verbose:
	@echo "🗑️  Running backup file cleanup (verbose)..."
	@$(SCRIPTS_DIR)/pm-manager.sh backup-clean --verbose

pm-install:
	@echo "📦 Installing packages from package list..."
	@$(SCRIPTS_DIR)/pm-manager.sh install

pm-install-dry:
	@echo "📦 Installing packages from package list (dry run)..."
	@$(SCRIPTS_DIR)/pm-manager.sh install --dry-run

pm-install-verbose:
	@echo "📦 Installing packages from package list (verbose)..."
	@$(SCRIPTS_DIR)/pm-manager.sh install --verbose

pm-sync-to-master:
	@echo "📤 Syncing computer package list to master..."
	@$(SCRIPTS_DIR)/pm-manager.sh sync to-master

pm-sync-from-master:
	@echo "📥 Syncing master package list to computer..."
	@$(SCRIPTS_DIR)/pm-manager.sh sync from-master

pm-sync-diff:
	@echo "🔍 Showing differences between package lists..."
	@$(SCRIPTS_DIR)/pm-manager.sh sync diff

# System Maintenance
maintenance: maint
maint:
	@echo "🔧 Running full system maintenance..."
	@echo "🔒 Running security audit..."
	@$(SCRIPTS_DIR)/security-audit.sh
	@echo "🧹 Running package manager cleanup..."
	@$(SCRIPTS_DIR)/pm-manager.sh clean
	@echo "🗑️  Running backup file cleanup..."
	@$(SCRIPTS_DIR)/pm-manager.sh backup-clean
	@echo "📦 Backing up dotfiles..."
	@if [ -d "$$HOME/jdots" ] && [ -f "$$HOME/jdots/Makefile" ]; then \
		echo "✅ Found jdots directory, running stow-backup..."; \
		make -C ~/jdots stow-backup; \
	else \
		echo "⚠️  jdots directory not found at ~/jdots, skipping stow-backup"; \
	fi
	@echo "✅ Full system maintenance complete!"
	# TODO: Fix git prompt interaction when running stow-backup from maintenance
	# Current issue: read prompt doesn't work in non-interactive make context
	# TODO: Fix pm backup-clean prompt interaction when running from maintenance
	# Current issue: read prompt doesn't work in non-interactive make context

# New Computer Setup
setup-new:
	@echo "🚀 Setting up new computer..."
	@echo ""
	@echo "Step 1: Ensuring package manager is available..."
	@$(SCRIPTS_DIR)/pm-utils.sh
	@echo "✅ Package manager detected and available"
	@echo ""
	@echo "Step 2: Installing and restoring ASDF..."
	@echo "📦 Installing ASDF..."
	@$(SCRIPTS_DIR)/asdf-install.sh
	@echo "🔄 Restoring ASDF packages and versions..."
	@$(SCRIPTS_DIR)/asdf-restore.sh
	@echo "✅ ASDF setup complete"
	@echo ""
	@echo "Step 3: Installing system packages..."
	@echo "📥 Syncing package lists from master..."
	@$(SCRIPTS_DIR)/pm-manager.sh sync from-master
	@echo "📦 Installing packages..."
	@$(SCRIPTS_DIR)/pm-manager.sh install
	@echo ""
	@echo "✅ New computer setup complete!"
	@echo "📋 Summary: Package manager → ASDF → System packages"