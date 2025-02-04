# Yggdrasil Profile Switcher
Profile switcher script for Yggdrasil Network (https://yggdrasil-network.github.io/)

## Preparation
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
