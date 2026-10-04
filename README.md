# SoapyRemote-server-installer

[![CI](https://github.com/hmol33/SoapyRemote-server-installer/actions/workflows/ci.yml/badge.svg)](https://github.com/hmol33/SoapyRemote-server-installer/actions)
[![Stars](https://img.shields.io/github/stars/hmol33/SoapyRemote-server-installer?style=flat-square&color=blue)](https://github.com/hmol33/SoapyRemote-server-installer/stargazers)
[![License](https://img.shields.io/github/license/hmol33/SoapyRemote-server-installer?style=flat-square)](LICENSE)

Install SoapyRemote server on debian, ubuntu, fedora or redhat.

## Vereisten

- Debian, Ubuntu, Fedora of RHEL
- sudo rechten
- Internetverbinding

## Installatie

```bash
bash <(curl -Ls https://raw.githubusercontent.com/hmol33/SoapyRemote-server-installer/master/SoapyRemote-server-installer.sh)
```

## Wat het script doet

1. Installeert build dependencies (git, gcc, g++, make, cmake)
2. Clone en compileert SoapySDR
3. Installeert SDR hardware drivers (rtl-sdr)
4. Clone en compileert SoapyRTLSDR
5. Controleert SoapySDR hardware detectie
6. Clone en compileert SoapyRemote
7. Start SoapyRemote server (alle interfaces of specifiek IP)

## Gebruik

Na installatie: verbind met SoapyRemote via SoapySDR op poort 55132

## Bijdragers

- [hmol33](https://github.com/hmol33) — Onderhouder

## Licentie

MIT — zie [LICENSE](LICENSE) voor details.
