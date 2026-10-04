# SoapyRemote-server-installer

<img src="https://img.shields.io/github/stars/hmol33/SoapyRemote-server-installer?style=flat-square&color=blue" alt="Stars">
<img src="https://img.shields.io/github/forks/hmol33/SoapyRemote-server-installer?style=flat-square&color=green" alt="Forks">
<img src="https://img.shields.io/github/license/hmol33/SoapyRemote-server-installer?style=flat-square" alt="License">
<img src="https://github.com/hmol33/SoapyRemote-server-installer/workflows/CI/badge.svg" alt="CI">

Install SoapyRemote server on debian, ubuntu, fedora or redhat.

## Installatie

```bash
bash <(curl -Ls https://raw.githubusercontent.com/hmol33/SoapyRemote-server-installer/master/SoapyRemote-server-installer.sh)
```

## Gebruik

```bash
# Voer het installatiescript uit
bash <(curl -Ls https://raw.githubusercontent.com/hmol33/SoapyRemote-server-installer/master/SoapyRemote-server-installer.sh)

# Volg de instructies op het scherm
# Na installatie: verbind met SoapyRemote via SoapySDR
```

## Opties

| Variabele | Default | Beschrijving |
|-----------|---------|--------------|
| `DRY_RUN` | (leeg) | Zet op `1` voor dry-run mode (geen wijzigingen) |
| `LOG_FILE` | `/tmp/soapyremote-installer.log` | Pad naar log bestand |
| `INSTALL_DIR` | `$HOME/soapyremote-install` | Installatie directory |

### Voorbeelden

```bash
# Dry-run (test zonder wijzigingen)
DRY_RUN=1 bash <(curl -Ls https://raw.githubusercontent.com/hmol33/SoapyRemote-server-installer/master/SoapyRemote-server-installer.sh)

# Custom installatie directory
INSTALL_DIR=/opt/soapyremote bash <(curl -Ls https://raw.githubusercontent.com/hmol33/SoapyRemote-server-installer/master/SoapyRemote-server-installer.sh)
```

## Features

- Automatische OS detectie (Debian/Ubuntu/Fedora/RHEL)
- Automatische dependency check
- Error handling met cleanup trap
- DRY_RUN mode voor veilig testen
- Structured logging
- GitHub Actions CI (shellcheck)

## Bijdragers

- [hmol33](https://github.com/hmol33) — Onderhouder

## Licentie

MIT — zie [LICENSE](LICENSE) voor details.
