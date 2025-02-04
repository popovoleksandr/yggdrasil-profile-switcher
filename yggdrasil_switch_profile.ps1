## Auto-elevate script to run as Administrator if not already elevated
#if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
#    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
#    exit
#}

# Check if required commands are available
function CommandExists {
    param ($command)
    Get-Command $command -ErrorAction SilentlyContinue
}
# Function to prompt user to press any key before exiting
function WaitForKeyPress {
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$missingPackages = @()

foreach ($cmd in @("jq")) {
    if (-not (CommandExists $cmd)) {
        $missingPackages += $cmd
    }
}

if (-not (CommandExists "yggdrasil")) {
    $missingPackages += "yggdrasil"
}

if ($missingPackages.Count -ne 0) {
    Write-Host "The following required packages are missing:"
    $missingPackages | ForEach-Object { Write-Host "  - $_" }
    WaitForKeyPress
    exit 1
}

# Check if parameters are provided
if ($args.Count -lt 2) {
    Write-Host "Usage: yggdrasil_switch_profile.ps1 <config_file_path> <profile_name>"
    WaitForKeyPress
    exit 1
}

$MAIN_CONFIG_FILE = $args[0]
$PROFILE_NAME = $args[1]

# Check if main configuration JSON file exists
if (-not (Test-Path $MAIN_CONFIG_FILE)) {
    Write-Host "Main config file '$MAIN_CONFIG_FILE' does not exist."
    WaitForKeyPress
    exit 1
}

# Extract the config file path from the main JSON file
$CONFIG_FILE = (Get-Content $MAIN_CONFIG_FILE | jq -r '.ConfigFilePath') + "\yggdrasil.conf"

if (-not (Test-Path $CONFIG_FILE)) {
    Write-Host "Config file '$CONFIG_FILE' does not exist."
    WaitForKeyPress
    exit 1
}

# Extract peers for the selected profile
$PEERS = (Get-Content $MAIN_CONFIG_FILE | jq -r --arg PROFILE_NAME "$PROFILE_NAME" '.Profiles[] | select(.name == $PROFILE_NAME) | .peers | join(\",\")')
#Write-Host "Extracted Peers: $PEERS"

if ([string]::IsNullOrWhiteSpace($PEERS)) {
    Write-Host "Profile '$PROFILE_NAME' not found in the config file."
    WaitForKeyPress
    exit 1
}

# Create a backup of the Yggdrasil config file
$timestamp = Get-Date -Format "yyyyMMddHHmm"
Copy-Item -Path $CONFIG_FILE -Destination "$CONFIG_FILE.$timestamp.bak" -Force

# Update the Peers section in the Yggdrasil config file
#(Get-Content $CONFIG_FILE) -replace '(Peers: \[)[^\]]*(\])', "`$1`\n    $PEERS`\n`$2" | Set-Content $CONFIG_FILE
# Read the content into a single string
$content = Get-Content $CONFIG_FILE -Raw

# Properly format the Peers list
$PEERS_LIST = $PEERS -replace ",", "`r`n    "

# Replace the Peers section with formatted peers list
$content = $content -replace '(Peers:\s*\[)[^\]]*(\])', "`$1`r`n    $PEERS_LIST`r`n  `$2"
#$content = $content -replace '(Peers:\s*\[)[^\]]*(\])', "`$1`r`n    $PEERS`r`n  `$2"

# Write the updated content back to the file
Set-Content -Path $CONFIG_FILE -Value $content -Force

# Restart the Yggdrasil service
$serviceName = "yggdrasil"
#if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
#    Restart-Service -Name $serviceName -Force
#    if ($?) {
#        Write-Host "Switched to profile '$PROFILE_NAME' and restarted Yggdrasil service."
#    } else {
#        Write-Host "Failed to restart the Yggdrasil service"
#        exit 1
#    }
#} else {
#    Write-Host "Service '$serviceName' not found. Ensure Yggdrasil is installed and registered as a Windows service."
#    exit 1
#}

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service) {
    if ($service.Status -eq "Running") {
        Stop-Service -Name $serviceName -Force
        Start-Service -Name $serviceName
    } else {
        Start-Service -Name $serviceName
    }

    if ($?) {
        Write-Host "Switched to profile '$PROFILE_NAME' and restarted Yggdrasil service."
    } else {
        Write-Host "Failed to restart the Yggdrasil service"
        exit 1
    }
} else {
    Write-Host "Service '$serviceName' not found. Trying manual restart..."

    # Attempt to restart manually if not a registered service
    taskkill /F /IM yggdrasil.exe
    Start-Process -FilePath "C:\Program Files\Yggdrasil\yggdrasil.exe" -ArgumentList "-useconfig C:\ProgramData\Yggdrasil\config.json" -NoNewWindow
    Write-Host "Yggdrasil restarted manually."
}

# Prompt user to press any key before exiting
WaitForKeyPress
