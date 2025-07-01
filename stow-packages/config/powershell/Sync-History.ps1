# Sync-History.ps1
# Copies and cleans shared history for PowerShell

param(
    [string]$SharedHistoryFile = "$env:HOME/.config/.history",
    [string]$PowerShellHistoryFile = "$env:HOME/.local/share/powershell/PSReadLine/ConsoleHost_history.txt"
)

# Check if shared history file exists
if (-not (Test-Path $SharedHistoryFile)) {
    Write-Host "Shared history file not found: $SharedHistoryFile" -ForegroundColor Yellow
    exit 1
}

try {
    # Read shared history and clean timestamps
    $lines = Get-Content $SharedHistoryFile
    
    # Clean timestamps and filter out empty lines
    $cleanCommands = $lines | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^: \d+:\d+;(.+)$') {
            $matches[1].Trim()
        } elseif (-not [string]::IsNullOrWhiteSpace($line)) {
            $line
        }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    
    # Write to PowerShell history file
    $cleanCommands | Out-File $PowerShellHistoryFile -Encoding UTF8
    
    Write-Host "Synced $($cleanCommands.Count) commands to PowerShell history" -ForegroundColor Green
}
catch {
    Write-Host "Error syncing history: $($_.Exception.Message)" -ForegroundColor Red
} 