# Makefile for jdots stow management
# Manages .config files using GNU stow

.PHONY: help stow-backup stow-restore stow-add-new stow-deploy stow-clean stow-status stow-install-deps

# Default target
help:
	@echo "jdots management commands:"
	@echo ""
	@echo "Stow Configuration Management:"
	@echo "  stow-backup    - Backup .config files to stow packages"
	@echo "  stow-restore   - Restore .config files from stow packages"
	@echo "  stow-add-new   - Add new .config directories to stow packages"
	@echo "  stow-deploy    - Deploy stow packages to ~/.config"
	@echo "  stow-clean     - Clean up stow packages (remove symlinks)"
	@echo "  stow-status    - Show status of stow packages"
	@echo "  stow-install-deps - Install dependencies for dotfiles"
	@echo ""
	@echo "System Maintenance:"
	@echo "  brewclean      - Comprehensive Homebrew cleanup and maintenance"
	@echo "  brewclean-dry  - Homebrew cleanup (dry run - show what would be cleaned)"
	@echo "  brewupdate     - Update and upgrade Homebrew packages"
	@echo "  brewdoctor     - Run Homebrew doctor to check for issues"
	@echo "  maintenance    - Full system maintenance (brew cleanup + stow backup)"
	@echo ""
	@echo "  help           - Show this help message"
	@echo ""

# Backup .config files to stow packages
stow-backup:
	@echo "Backing up .config files to stow packages..."
	@chmod +x scripts/stow/backup-config.sh
	@./scripts/stow/backup-config.sh

# Restore .config files from stow packages
stow-restore:
	@echo "Restoring .config files from stow packages..."
	@chmod +x scripts/stow/restore-config.sh
	@./scripts/stow/restore-config.sh

# Add new .config directories to stow packages
stow-add-new:
	@echo "Scanning for new .config directories..."
	@chmod +x scripts/stow/add-new-configs.sh
	@./scripts/stow/add-new-configs.sh

# Install dependencies for dotfiles
stow-install-deps:
	@echo "Installing dependencies for dotfiles..."
	@chmod +x scripts/stow/install-dependencies.sh
	@./scripts/stow/install-dependencies.sh

# Deploy stow packages to ~/.config
stow-deploy:
	@echo "Deploying stow packages to ~/.config..."
	@if [ ! -d "stow-packages" ]; then \
		echo "Error: stow-packages directory not found. Run 'make stow-backup' first."; \
		exit 1; \
	fi
	@cd stow-packages && for package in */; do \
		if [ -d "$$package" ]; then \
			echo "Deploying $$(basename "$$package")..."; \
			stow -t ~/.config "$$(basename "$$package")" 2>/dev/null || echo "Warning: Failed to deploy $$(basename "$$package")"; \
		fi; \
	done
	@echo "Stow deployment completed!"

# Clean up stow packages (remove symlinks)
stow-clean:
	@echo "Cleaning up stow packages..."
	@if [ ! -d "stow-packages" ]; then \
		echo "Error: stow-packages directory not found."; \
		exit 1; \
	fi
	@cd stow-packages && for package in */; do \
		if [ -d "$$package" ]; then \
			echo "Cleaning $$(basename "$$package")..."; \
			stow -D -t ~/.config "$$(basename "$$package")" 2>/dev/null || echo "Warning: Failed to clean $$(basename "$$package")"; \
		fi; \
	done
	@echo "Stow cleanup completed!"

# Show status of stow packages
stow-status:
	@echo "Stow package status:"
	@echo ""
	@if [ ! -d "stow-packages" ]; then \
		echo "  No stow-packages directory found."; \
		echo "  Run 'make stow-backup' to create stow packages."; \
		exit 0; \
	fi
	@cd stow-packages && for package in */; do \
		if [ -d "$$package" ]; then \
			package_name="$$(basename "$$package")"; \
			echo "  $$package_name:"; \
			if stow -t ~/.config -n "$$package_name" 2>/dev/null | grep -q "LINK"; then \
				echo "    Status: Deployed (symlinks exist)"; \
			else \
				echo "    Status: Not deployed (no symlinks)"; \
			fi; \
			echo "    Files: $$(find "$$package" -type f | wc -l | tr -d ' ')"; \
			echo ""; \
		fi; \
	done

# Full workflow: backup, add new, and deploy
stow-full: stow-backup stow-add-new stow-deploy
	@echo "Full stow workflow completed!"

# Initialize stow setup (first time setup)
stow-init: stow-backup stow-deploy
	@echo "Stow initialization completed!"
	@echo "Your .config files are now managed by stow."
	@echo "Use 'make stow-status' to check the status of your packages."

# =============================================================================
# System Maintenance Commands
# =============================================================================

# Homebrew cleanup and maintenance
brewclean:
	@echo "🧹 Starting Homebrew cleanup..."
	@chmod +x scripts/brewclean/brewclean.sh
	@./scripts/brewclean/brewclean.sh

# Homebrew cleanup (dry run - show what would be cleaned)
brewclean-dry:
	@echo "🧹 Homebrew cleanup (dry run)..."
	@brew cleanup --dry-run

# Homebrew update and upgrade
brewupdate:
	@echo "📦 Updating Homebrew packages..."
	@brew update
	@brew upgrade

# Homebrew doctor check
brewdoctor:
	@echo "🔧 Running Homebrew doctor..."
	@brew doctor

# Full system maintenance (brew cleanup + stow backup)
maintenance: brewclean stow-backup
	@echo "✅ System maintenance completed!"
	@echo "Homebrew cleaned and .config files backed up." 