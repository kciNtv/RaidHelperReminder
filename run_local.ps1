# Runs the reminder script on your own PC.
#
# One-time setup:
#   1. Copy secrets.example.env to secrets.local.env and fill in the two values.
#      (secrets.local.env is gitignored - it never leaves your machine.)
#   2. Copy config.example.json to config.json and fill in your ids.
#   3. Test it:   powershell -File run_local.ps1 -DryRun
#
# Schedule it (Task Scheduler uses your PC's local timezone):
#   schtasks /Create /TN "RaidAnnouncements" /SC MINUTE /MO 15 ^
#     /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\path\to\run_local.ps1\" -Mode announcements"
#   schtasks /Create /TN "RaidReminders" /SC WEEKLY /D FRI /ST 17:00 ^
#     /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\path\to\run_local.ps1\" -Mode reminders"

param(
    [switch]$DryRun,
    [ValidateSet("all", "reminders", "announcements")]
    [string]$Mode = "all"
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$secretsFile = Join-Path $here "secrets.local.env"

if (-not (Test-Path $secretsFile)) {
    Write-Error "Missing $secretsFile - copy secrets.example.env and fill it in."
    exit 1
}

# Load KEY=VALUE lines into environment variables for this process only.
Get-Content $secretsFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        $name, $value = $line -split "=", 2
        Set-Item -Path ("Env:" + $name.Trim()) -Value $value.Trim()
    }
}

$scriptArgs = @((Join-Path $here "remind.py"), "--mode", $Mode)
if ($DryRun) { $scriptArgs += "--dry-run" }

python @scriptArgs
exit $LASTEXITCODE
