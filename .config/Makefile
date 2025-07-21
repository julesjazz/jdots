.PHONY: \
identities-setup \
aws-gen-config \
scan-filetypes \
check-config

# Notes:
# - returns including "make: '_' is up to date." are an expected output bug with makefile, not worth fixing.

# Handle additional arguments as target directories (prevents "No rule to make target" errors)
%:
	@:

help:
	@echo "\033[1;36m🚀 Usage: make <target>\033[0m"
	@echo "--------------------------------"
	@echo "\033[1;33m☁️  AWS Tools:\033[0m"
	@echo "  \033[1;32m🔐 identities-setup\033[0m - Setup identities for gitlab and github ⚠️"
	@echo "  \033[1;32m⚙️  aws-gen-config\033[0m - Generate AWS config, update aws accounts"
	@echo "--------------------------------"
	@echo "\033[1;33m🛠️  Utilities:\033[0m"
	@echo "  \033[1;32m📁 scan-filetypes\033[0m - Scan with: make scan-filetypes <targetdir>"
	@echo "  \033[1;32m📁 check-config\033[0m - Check for .config changes"

# --- Enabling statements ---
# Handle additional arguments as target directories (prevents "No rule to make target" errors)
%:
	@:
# Get the target directory from command line arguments
TARGET_DIR := $(word 2,$(MAKECMDGOALS))

identities-setup:
	@echo -n "\033[1;33m⚠️  This will break working git repos. Continue? (y/N): \033[0m" && read -r response \
	&& [ "$$response" = "y" ] || [ "$$response" = "Y" ] \
	&& bash ./scripts/identities-setup.sh || echo "\033[1;31m❌ Setup cancelled\033[0m"

aws-gen-config:
	@echo -n "\033[1;33m⚠️  This may break AWS configuration. Continue? (y/N): \033[0m" && read -r response \
	&& [ "$$response" = "y" ] || [ "$$response" = "Y" ] \
	&& bash ./scripts/aws-gen-config.sh || echo "\033[1;31m❌ Generation cancelled\033[0m"

scan-filetypes:
	@echo -n "\033[1;33m⚠️  This may take a while for large directories. Continue? (y/N): \033[0m" && \
	read -r response && [ "$$response" = "y" ] || [ "$$response" = "Y" ] || \
	{ echo "\033[1;31m❌ Scan cancelled\033[0m"; exit 1; } && \
	bash ./scripts/scan-filetypes.sh $(or $(TARGETDIR),$(TARGET_DIR),.) && \
	echo "\033[1;32m✅ Scan complete 👉 ~/.config/scripts/temp/filetypes.txt\033[0m"

obsidian-sync:
	@echo -n "\033[1;33m⚠️  Copy targeted vault config to another. Continue? (y/N): \033[0m" && read -r response \
	&& [ "$$response" = "y" ] || [ "$$response" = "Y" ] \
	&& bash ./scripts/obsidian-sync.sh || echo "\033[1;31m❌ Sync cancelled\033[0m"

check-config:
	@bash ~/.config/scripts/check-config.sh