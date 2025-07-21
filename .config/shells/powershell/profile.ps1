# Load Homebrew environment
$(/opt/homebrew/bin/brew shellenv) | Invoke-Expression

# Initialize Oh My Posh if available
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config /opt/homebrew/opt/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression
} else {
    Write-Host "Oh My Posh not found. Install with: brew install oh-my-posh" -ForegroundColor Yellow
}

# Sync history from bash/zsh on startup
$SyncScript = Join-Path $PSScriptRoot "Sync-History.ps1"
if (Test-Path $SyncScript) {
    & $SyncScript | Out-Null
}


