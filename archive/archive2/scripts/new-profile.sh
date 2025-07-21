#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# setup-profile-env.sh: Interactive script to populate profile.env securely
# -----------------------------------------------------------------------------

PROFILE_ENV="$(cd "$(dirname "$0")/.." && pwd)/profile.env"

echo "\n📋 Setting up your dotfiles environment configuration"
echo "----------------------------------------------------"

# Helper to safely append with divider if needed
append() {
  echo "$1" >> "$PROFILE_ENV"
}

confirm_section() {
  local prompt="$1"
  read -r -p "$prompt [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] && return 0 || return 1
}

write_divider() {
  echo "" >> "$PROFILE_ENV"
  echo "# ===============================================" >> "$PROFILE_ENV"
  echo "# $1" >> "$PROFILE_ENV"
  echo "# ===============================================" >> "$PROFILE_ENV"
}

# Initialize profile.env
> "$PROFILE_ENV"

# ------------------------------------
write_divider "📝 Manually Defined (Static)"
echo "# Personal Information" >> "$PROFILE_ENV"
read -r -p "👤 First Name: " FIRST_NAME
read -r -p "👤 Last Name:  " LAST_NAME
read -r -p "📧 Personal Email: " PERSONAL_EMAIL
read -r -p "💼 Work Email (optional): " WORK_EMAIL
read -r -p "🌍 Country: " COUNTRY
read -r -p "🏙️  State: " STATE

append "FIRST_NAME=$FIRST_NAME"
append "LAST_NAME=$LAST_NAME"
append "PERSONAL_EMAIL=$PERSONAL_EMAIL"
append "WORK_EMAIL=$WORK_EMAIL"
append "COUNTRY=$COUNTRY"
append "STATE=$STATE"

append "DOTFILES_CONTEXT=dev"

# ------------------------------------
write_divider "🔐 GPG Info (signing key)"
append "GPG_NAME=\"\${FIRST_NAME} \${LAST_NAME}\""
append "GPG_EMAIL=\"\${WORK_EMAIL:-\${PERSONAL_EMAIL}}\""
append "GPG_KEY_TYPE=ed25519"
append "GPG_KEY_EXPIRE=2y"

# ------------------------------------
write_divider "☁️ AWS (optional)"
read -r -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -r -p "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
append "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
append "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"

# ------------------------------------
write_divider "🌐 Git Defaults"
append "GIT_DEFAULT_PERSONAL_BRANCH=main"
append "GIT_DEFAULT_WORK_BRANCH=main"
append "GIT_EDITOR=nvim"
append "GIT_PAGER=less"

# ------------------------------------
if confirm_section "🔐 Add GitHub personal account?"; then
  write_divider "🐙 GitHub - Personal"
  read -r -p "GitHub Username: " gh_user
  read -r -p "GitHub Email: " gh_email
  read -r -p "GitHub Token: " gh_token
  append "GITHUB_PERSONAL_USER=$gh_user"
  append "GITHUB_PERSONAL_EMAIL=$gh_email"
  append "GITHUB_PERSONAL_URL=https://github.com/$gh_user"
  append "GITHUB_PERSONAL_SSH=git@github.com:$gh_user"
  append "GITHUB_PERSONAL_TOKEN=$gh_token"
fi

# ------------------------------------
if confirm_section "🏢 Add GitHub work account?"; then
  write_divider "🐙 GitHub - Work"
  read -r -p "Work Username: " gh_user
  read -r -p "Work Email: " gh_email
  read -r -p "Work Token: " gh_token
  append "GITHUB_WORK_USER=$gh_user"
  append "GITHUB_WORK_EMAIL=$gh_email"
  append "GITHUB_WORK_URL=https://github.com/$gh_user"
  append "GITHUB_WORK_SSH=git@github.com:$gh_user"
  append "GITHUB_WORK_TOKEN=$gh_token"
fi

# ------------------------------------
if confirm_section "📁 Add GitLab personal account?"; then
  write_divider "🦊 GitLab - Personal"
  read -r -p "GitLab Username: " gl_user
  read -r -p "GitLab Email: " gl_email
  append "GITLAB_PERSONAL_USER=$gl_user"
  append "GITLAB_PERSONAL_EMAIL=$gl_email"
  append "GITLAB_PERSONAL_URL=https://gitlab.com/$gl_user"
  append "GITLAB_PERSONAL_SSH=git@gitlab.com:$gl_user"
fi

# ------------------------------------
if confirm_section "🏢 Add GitLab work account?"; then
  write_divider "🦊 GitLab - Work"
  read -r -p "Work Username: " gl_user
  read -r -p "Work Email: " gl_email
  read -r -p "Group or Org URL (e.g., gitlab.com/companyname): " gl_url
  append "GITLAB_WORK_USER=$gl_user"
  append "GITLAB_WORK_EMAIL=$gl_email"
  append "GITLAB_WORK_URL=https://$gl_url"
  append "GITLAB_WORK_SSH=git@$gl_url"
fi

# ------------------------------------
echo "\n✅ Done. Saved profile to: $PROFILE_ENV"
