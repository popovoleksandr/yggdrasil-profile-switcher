# Yggdrasil Profile Switcher
Profile switcher script for Yggdrasil Network (https://yggdrasil-network.github.io/)

## Preparation
### Install package manager
#### Homebrew for mac

Open Terminal:
You can find Terminal in Applications > Utilities, or search for it using Spotlight.

Install Command Line Tools (if needed):
If you haven’t installed Apple’s Command Line Tools already, run:

```bash
xcode-select --install
```

This installs essential tools that Homebrew relies on.

Run the Homebrew Installation Command:
Paste the following command into your Terminal and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This script will download and install Homebrew on your system. Follow the on-screen prompts—it may ask for your administrator password.

Verify the Installation:
Once the installation is complete, check that Homebrew is installed by running:

```bash
brew --version
````
This command should return the version number of Homebrew.

#### Chocolatey for Windows

1. Open an Elevated PowerShell
Search for “PowerShell” in your Start menu.
Right-click on "Windows PowerShell" and select Run as Administrator.

2. (Optional) Set the Execution Policy
To temporarily allow the installation script to run, enter the following command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

This command temporarily bypasses the execution policy restrictions for the current session.

3. Run the Installation Command
Copy and paste the following command into your elevated PowerShell window and press Enter:

```powershell
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

This script will download and run the Chocolatey installation script from the official website.

4. Verify the Installation
After the installation completes:

Close and reopen your PowerShell window (or Command Prompt).
Type the command below to check your installed version:

```powershell
choco --version
```

You should see the version number of Chocolatey, confirming that the installation was successful.

### Dependencies
#### jq
```bash
brew install jq
```
for Windows:
```powershell
choco install jq -y
```

#### yggdrasil
Install it.

For windows - add it to `PATH` variable

### Configuration
Run:
```bash
cp config.example.json config.json
```

and edit `config.json` to add peers. One of the options you can use public peers from https://github.com/yggdrasil-network/public-peers

Do not forget to modify `ConfigFilePath` since for different OSes it might be different location. For example:
- Ubuntu `/etc/yggdrasil/yggdrasil.conf` 
- MacOS `/etc/yggdrasil.conf`
- Windows `C:\\ProgramData\\Yggdrasil`

## Running script

```bash
sudo ./yggdrasil_switch_profile.sh ./config.json dev
```

You need to run this from Administrator PowerShell or it will be auto-elevated by script:
```powershell
powershell .\yggdrasil_switch_profile.ps1 .\config.json dev
```
