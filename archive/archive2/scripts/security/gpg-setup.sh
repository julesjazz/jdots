#!/usr/bin/env bash
set -euo pipefail

echo "🔐 Checking for GPG key for $$GPG_EMAIL..."; \
		if gpg --list-secret-keys --with-colons "$$GPG_EMAIL" | grep -q "^sec"; then \
			echo "✅ GPG key already exists for $$GPG_EMAIL"; \
			echo ""; \
			echo "📤 Public GPG key (paste into GitHub/GitLab):"; \
			gpg --armor --export "$$GPG_EMAIL"; \
		else \
			echo "🔧 Generating new GPG key for $$GPG_NAME <$$GPG_EMAIL>..."; \
			TMP_FILE=$$(mktemp); \
			echo "Key-Type: $$GPG_KEY_TYPE" > $$TMP_FILE; \
			echo "Key-Length: 255" >> $$TMP_FILE; \
			echo "Name-Real: $$GPG_NAME" >> $$TMP_FILE; \
			echo "Name-Email: $$GPG_EMAIL" >> $$TMP_FILE; \
			echo "Expire-Date: $$GPG_KEY_EXPIRE" >> $$TMP_FILE; \
			echo "%no-protection" >> $$TMP_FILE; \
			echo "%commit" >> $$TMP_FILE; \
			gpg --batch --generate-key $$TMP_FILE; \
			echo "🔐 GPG key generated successfully, hold on..."; \
			sleep 5; \
			rm -f $$TMP_FILE; \
			FPR=$$(gpg --list-secret-keys --with-colons "$$GPG_EMAIL" | awk -F: '/^fpr:/ { print $$10; exit }'); \
			git config --global user.signingkey "$$FPR"; \
			git config --global commit.gpgsign true; \
			echo "✅ Git now signs commits with: $$FPR"; \
			echo ""; \
			echo "📤 Public GPG key (paste into GitHub/GitLab):"; \
			gpg --armor --export "$$GPG_EMAIL"; \
		fi;