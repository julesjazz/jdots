#!/usr/bin/env bash
set -euo pipefail

INSTALL_GUI=false; \
		if [[ "$$OS_TYPE" == "Darwin" ]]; then \
			INSTALL_GUI=true; \
		elif [[ "$$OS_TYPE" == "Linux" || "$$DISTRO" == "wsl" ]]; then \
			read -r -p "🖥️  Is this a GUI-enabled Linux/WSL system? [y/N] " response; \
			case "$$response" in \
				[yY][eE][sS]|[yY]) \
					INSTALL_GUI=true; \
					;; \
				*) \
					echo "⚠️  Skipping GUI application setup."; \
					;; \
			esac; \
		fi; \
		if [[ "$$INSTALL_GUI" == true ]]; then \
			echo "📦 Installing GUI applications..."; \
			for app in $$(yq '.packages.casks[]' $$PROFILE_FILE); do \
				brew install --cask "$$app"; \
			done; \
		else \
			echo "✅ Continuing without GUI package installation."; \
		fi;