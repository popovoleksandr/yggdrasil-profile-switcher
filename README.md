# Yggdrasil Profile Switcher
Profile switcher script for Yggdrasil Network

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

## Running script

```bash
sudo ./yggdrasil_switch_profile.sh ./config.json dev
```
