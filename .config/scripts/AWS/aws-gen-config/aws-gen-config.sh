#!/usr/bin/env bash
set -euo pipefail

SSO_SESSION="cli-access"
TEST_DIR="$(pwd)"
PUPPETEER_SCRIPT="$TEST_DIR/aws-gen-config.js"

# Output paths
CONFIG_DIR="$HOME/.aws"
GENERATED_FILE="$CONFIG_DIR/config.generated"
MERGED_FILE="$CONFIG_DIR/config.merged"

# Chromium path detection via PATH
detect_chromium_path() {
  local chromium_path
  chromium_path="$(which Chromium 2>/dev/null || true)"
  if [ -x "$chromium_path" ]; then
    echo "$chromium_path"
  else
    echo ""
  fi
}

# 1. Check for Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js is not installed. Please install it via https://nodejs.org/"
  exit 1
fi

# 2. Check for Chromium in PATH
CHROMIUM_PATH="$(detect_chromium_path)"
if [ -z "$CHROMIUM_PATH" ]; then
  echo "❌ Chromium is not installed or not in PATH."
  echo "👉 macOS: brew install --cask chromium"
  echo "👉 Linux: sudo apt install chromium-browser (or chromium)"
  exit 1
fi

# 3. Check for puppeteer-core globally
if ! npm list -g puppeteer-core --depth=0 >/dev/null 2>&1; then
  echo "❌ puppeteer-core is not installed globally."
  echo "👉 Install it with: npm install -g puppeteer-core"
  exit 1
fi

# 4. Set NODE_PATH to point to global modules
NODE_PATH="$(npm root -g)"

# 5. Run AWS SSO login
# echo "🔐 Logging in with AWS SSO session: $SSO_SESSION"
# aws sso login --sso-session "$SSO_SESSION"
# echo "✅ SSO login complete"

# 6. Run Puppeteer script and write to generated file
echo "🧠 Running Puppeteer to generate AWS config..."
NODE_PATH="$NODE_PATH" CHROMIUM_PATH="$CHROMIUM_PATH" node "$PUPPETEER_SCRIPT"

# 7. Move output to config.generated
mv ./aws-config.generated "$CONFIG_DIR/config.generated"
echo "✅ AWS config written to: $CONFIG_DIR/config.generated"

# 8. Merge config.personal + config.generated into final config (prefer generated)
if [ -f "$CONFIG_DIR/config.personal" ]; then
  echo "🔄 Merging config.personal and config.generated (deduplicating)..."

  # Collect profile names from generated config
  mapfile -t GENERATED_PROFILES < <(grep '^\[profile ' "$CONFIG_DIR/config.generated" | sed 's/^\[profile \(.*\)\]/\1/')

  # Create temporary filtered personal config
  PERSONAL_FILTERED=$(mktemp)
  current_profile=""
  skip_block=false

  while IFS= read -r line; do
    if [[ "$line" =~ ^\[profile\ (.*)\] ]]; then
      current_profile="${BASH_REMATCH[1]}"
      if printf '%s\n' "${GENERATED_PROFILES[@]}" | grep -qx "$current_profile"; then
        skip_block=true
      else
        skip_block=false
        echo "$line" >> "$PERSONAL_FILTERED"
      fi
    elif [[ "$line" =~ ^\[.*\] ]]; then
      # Other sections like [default] or [sso-session] — include them
      skip_block=false
      echo "$line" >> "$PERSONAL_FILTERED"
    elif [ "$skip_block" = false ]; then
      echo "$line" >> "$PERSONAL_FILTERED"
    fi
  done < "$CONFIG_DIR/config.personal"

  # Merge filtered personal with generated (generated comes last)
  cat "$PERSONAL_FILTERED" "$CONFIG_DIR/config.generated" > "$CONFIG_DIR/config"
  rm "$PERSONAL_FILTERED"

else
  echo "⚠️  Warning: $CONFIG_DIR/config.personal not found — using generated config only."
  cp "$CONFIG_DIR/config.generated" "$CONFIG_DIR/config"
fi

echo "✅ Final merged config written to: $CONFIG_DIR/config"

echo "✅ Final merged config written to: $CONFIG_DIR/config"

# 9. Print usage instructions
echo ""
echo "👉 To use merged config with AWS CLI:"
echo "   AWS_CONFIG_FILE=$MERGED_FILE aws s3 ls --profile <your-sso-profile>"
echo ""