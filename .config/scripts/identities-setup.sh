#!/usr/bin/env bash

set -euo pipefail

# Set up local identities for gpg/ssh for gitlab and github.
# destination files are in ~/.config/git/identities

BASE_DIR="$HOME/.config/git/identities"
mkdir -p "$BASE_DIR"

profiles=("personal" "work")
dry_run=false

for arg in "$@"; do
  case $arg in
    -n|--dry-run)
      dry_run=true
      echo "🧪 Dry run mode enabled."
      ;;
    *)
      echo "❌ Unknown argument: $arg"
      echo "Usage: $0 [--dry-run|-n]"
      exit 1
      ;;
  esac
done

echo "🔐 Identity Setup Script (GPG + SSH)"
echo "─────────────────────────────────────"

for profile in "${profiles[@]}"; do
  echo ""
  echo "🔧 Configuring profile: $profile"

  read -rp "  Enter full name: " name
  read -rp "  Enter email: " email

  ### GPG Handling ###
  gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep '^sec' | awk '{print $2}' | cut -d'/' -f2)
  gpg_export_path="$BASE_DIR/$profile-gpg.asc"

  do_gpg=true
  if [ -n "$gpg_key_id" ] || [ -f "$gpg_export_path" ]; then
    echo "  ⚠️ GPG key or export exists for $email"
    read -rp "  ❓ Remove and regenerate GPG key for $profile? [y/N] " gpg_confirm
    if [[ ! "$gpg_confirm" =~ ^[Yy]$ ]]; then
      do_gpg=false
      echo "  ⏭️ Skipping GPG setup for $profile."
    elif ! $dry_run; then
      [ -f "$gpg_export_path" ] && rm -f "$gpg_export_path"
    fi
  fi

  if $do_gpg; then
    if [ -z "$gpg_key_id" ]; then
      if $dry_run; then
        echo "  🧪 Would generate GPG key"
      else
        gpg --full-generate-key
        gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" | grep '^sec' | awk '{print $2}' | cut -d'/' -f2)
      fi
    fi

    if [ -n "$gpg_key_id" ]; then
      if $dry_run; then
        echo "  🧪 Would export GPG key to: $gpg_export_path"
      else
        gpg --armor --export "$gpg_key_id" > "$gpg_export_path"
        echo "  📤 Exported GPG key to: $gpg_export_path"
      fi
    fi
  fi

  ### SSH Handling ###
  ssh_key_file="$HOME/.ssh/id_ed25519_$profile"
  ssh_pubkey_file="$ssh_key_file.pub"
  ssh_out_path="$BASE_DIR/$profile-ssh.pub"

  do_ssh=true
  if [ -f "$ssh_key_file" ] || [ -f "$ssh_out_path" ]; then
    echo "  ⚠️ SSH key already exists for $profile"
    read -rp "  ❓ Remove and regenerate SSH key for $profile? [y/N] " ssh_confirm
    if [[ ! "$ssh_confirm" =~ ^[Yy]$ ]]; then
      do_ssh=false
      echo "  ⏭️ Skipping SSH setup for $profile."
    elif ! $dry_run; then
      rm -f "$ssh_key_file" "$ssh_pubkey_file" "$ssh_out_path" 2>/dev/null || true
    fi
  fi

  if $do_ssh; then
    if [ ! -f "$ssh_key_file" ]; then
      if $dry_run; then
        echo "  🧪 Would generate SSH key: $ssh_key_file"
      else
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_file" -N ""
        echo "  🔑 SSH key generated: $ssh_key_file"
      fi
    fi

    if [ -f "$ssh_pubkey_file" ]; then
      if $dry_run; then
        echo "  🧪 Would copy SSH pubkey to: $ssh_out_path"
      else
        cp "$ssh_pubkey_file" "$ssh_out_path"
        echo "  📤 SSH public key saved: $ssh_out_path"
      fi
    fi

    echo ""
    echo "🔧 Suggested ~/.ssh/config entry:"
    echo "----------------------------------"
    echo "Host github.com-$profile"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $ssh_key_file"
    echo "  IdentitiesOnly yes"
  fi

  ### Git Config ###
  gitconfig_path="$BASE_DIR/gitconfig-$profile"
  if $dry_run; then
    echo "  🧪 Would write Git config to: $gitconfig_path"
  else
    cat > "$gitconfig_path" <<EOF
[user]
	name = $name
	email = $email
$( [ -n "${gpg_key_id:-}" ] && echo "	signingkey = $gpg_key_id" )

[commit]
	gpgsign = true
EOF
    echo "  📝 Git config written to: $gitconfig_path"
  fi
done

echo ""
echo "✅ Identity setup complete."