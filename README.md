# Yggdrasil Profile Switcher
Profile switcher script for Yggdrasil Network (https://yggdrasil-network.github.io/)

## Preparation
### Dependencies
#### jq
```bash
brew install jq
```

### Configuration
Run:
```bash
cp config.example.json config.json
```

and edit `config.json` to add peers. One of the options you can use public peers from https://github.com/yggdrasil-network/public-peers

Do not forget to modify `ConfigFilePath` since for different OSes it might be different location (for example for Ubuntu it will be `/etc/yggdrasil/yggdrasil.conf` and for MacOS - `/etc/yggdrasil.conf`)

## Running script

```bash
sudo ./yggdrasil_switch_profile.sh ./config.json dev
```
