.PHONY: \
  help \
  new-install bootstrap check-deps \
  gpg-setup gpg-clip \
  asdf-backup asdf-install asdf-resolve \
  backup-config restore-config new-config \
  security-audit \
  pm-clean \
  pm-backup \
  pm-restore \
  pm-new-system \
  new-profile
#   todo: add GPG refresh script
#   todo: add a profile update script

SCRIPTS_DIR := ./scripts

# 📖 Help
help:
	@echo "\033[1;36mUsage: make <target>\033[0m"
	@echo ""
	@echo "\033[1;33m🔧 Setup:\033[0m"
	@echo "  \033[32mnew-install\033[0m       Install dependencies and bootstrap"
	@echo "  \033[32mbootstrap\033[0m         Bootstrap the system"
	@echo "  \033[32mcheck-deps\033[0m        Check dependencies"
	@echo ""
	@echo "\033[1;31m🔐 GPG:\033[0m"
	@echo "  \033[32mgpg-setup\033[0m         Setup GPG key and export"
	@echo "  \033[32mgpg-clip\033[0m          Copy GPG key to clipboard"
	@echo ""
	@echo "\033[1;31m🔒 Security:\033[0m"
	@echo "  \033[32msecurity-audit\033[0m  Audit for sensitive data"
	@echo ""
	@echo "\033[1;35m🧠 ASDF:\033[0m"
	@echo "  \033[32masdf-backup\033[0m       Backup plugin + tool config"
	@echo "  \033[32masdf-install\033[0m      Install asdf plugins + versions"
	@echo "  \033[32masdf-resolve\033[0m      Resolve LTS versions into profiles"
	@echo ""
	@echo "\033[1;34m🗂️  Dotfiles:\033[0m"
	@echo "  \033[32mbackup-config\033[0m     Backup + redact filtered dotfiles"
	@echo "  \033[32mrestore-config\033[0m    Restore redacted values from profile.env"
	@echo "  \033[32mnew-config\033[0m        Initial config backup on new system"
	@echo ""
	@echo "\033[1;33m🧹 Package Manager:\033[0m"
	@echo "  \033[32mpm-clean\033[0m        Clean package lists prior to backup or install"
	@echo "  \033[32mpm-backup\033[0m       Backup package lists"
	@echo "  \033[32mpm-restore\033[0m      Restore package lists"
	@echo "  \033[32mpm-new-system\033[0m   New system package install"
	@echo ""
	@echo "\033[1;36m🔄 Profile (new system):\033[0m"
	@echo "  \033[32mnew-profile\033[0m       New system profile setup"
	@echo ""
	@echo "\033[1;37m🧪 Dry Run:\033[0m"
	@echo "  \033[32mdry-run\033[0m         Simulate 'make new-install'"

# 🧰 Setup
new-install:
	bash $(SCRIPTS_DIR)/check-deps.sh
	bash $(SCRIPTS_DIR)/asdf/asdf-install.sh
	bash $(SCRIPTS_DIR)/bootstrap.sh

bootstrap:
	bash $(SCRIPTS_DIR)/bootstrap.sh

check-deps:
	bash $(SCRIPTS_DIR)/check-deps.sh

# 🔐 GPG
gpg-setup:
	bash $(SCRIPTS_DIR)/gpg-setup.sh

gpg-clip:
	@{ \
		if command -v pbcopy >/dev/null; then \
			gpg --armor --export "$$GPG_EMAIL" | pbcopy; \
			echo "✅ GPG key copied with pbcopy"; \
		elif command -v xclip >/dev/null; then \
			gpg --armor --export "$$GPG_EMAIL" | xclip -selection clipboard; \
			echo "✅ GPG key copied with xclip"; \
		else \
			echo "⚠️  Clipboard tool not found. Copy manually."; \
		fi; \
	}

# 🧠 ASDF
asdf-backup:
	bash $(SCRIPTS_DIR)/asdf/asdf-backup.sh

asdf-install:
	bash $(SCRIPTS_DIR)/asdf/asdf-install.sh

asdf-resolve:
	bash $(SCRIPTS_DIR)/asdf/resolve-asdf-versions.sh

# 🔁 Config
backup-config:
	bash $(SCRIPTS_DIR)/sync/sync-config.sh backup-redact

restore-config:
	bash $(SCRIPTS_DIR)/sync/sync-config.sh restore

new-config:
	bash $(SCRIPTS_DIR)/sync/sync-config.sh new-install

# 🔒 Security
security-audit:
	@echo "🔐 Running gitleaks audit..."
	@gitleaks detect --config=gitleaks.toml --source=. --report-format=table

# 🧹 Package Manager
pm-clean:
	bash $(SCRIPTS_DIR)/pkgs/pm-clean.sh

pm-backup:
	bash $(SCRIPTS_DIR)/pkgs/pm-backup.sh

pm-restore:
	bash $(SCRIPTS_DIR)/pkgs/pm-restore.sh

pm-new-system:
	bash $(SCRIPTS_DIR)/pkgs/pm-new-install.sh

# 🔄 Profile (new system)
new-profile:
	bash $(SCRIPTS_DIR)/profile/new-profile.sh

dry-run:
	@echo "🧪 Dry Run: Simulating 'make new-install'"
	@echo "-----------------------------------------"
	@echo "1️⃣  Checking dependencies..."
	@echo "Would run: bash $(SCRIPTS_DIR)/check-deps.sh"
	@echo "2️⃣  Installing asdf and plugins..."
	@echo "Would run: bash $(SCRIPTS_DIR)/asdf/asdf-install.sh"
	@echo "3️⃣  Bootstrapping dotfiles..."
	@echo "Would run: bash $(SCRIPTS_DIR)/bootstrap.sh"
	@echo "4️⃣  Installing system packages..."
	@echo "Would run: bash $(SCRIPTS_DIR)/pkgs/pm-new-install.sh"
	@echo "5️⃣  Verifying profile.env..."
	@if [ ! -f profile.env ]; then \
	  echo "⚠️  profile.env not found. You should run: make new-profile"; \
	else \
	  echo "✅ profile.env found."; \
	fi
	@echo "-----------------------------------------"
	@echo "✅ Dry run complete. No actions were taken."