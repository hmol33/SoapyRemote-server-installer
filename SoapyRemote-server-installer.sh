#!/bin/bash
set -euo pipefail

# SoapyRemote-server-installer: installeert SoapySDR + SoapyRemote server
# Gebruik: bash SoapyRemote-server-installer.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Detecteer OS
if [ -f /etc/debian_version ]; then
  OS="debian"
  PKG_MANAGER="apt-get"
elif [ -f /etc/redhat-release ]; then
  OS="redhat"
  PKG_MANAGER="dnf"
else
  echo "Onbekend OS. Installeer handmatig: git gcc g++ make cmake"
  exit 1
fi

# Installeer build dependencies
echo "Installing build dependencies..."
sudo "$PKG_MANAGER" update
sudo "$PKG_MANAGER" install -y git gcc g++ make cmake

# Compileer en installeer SoapySDR
if [ ! -d SoapySDR ]; then
  git clone https://github.com/pothosware/SoapySDR.git
fi
cd SoapySDR
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

# Installeer SDR hardware drivers (RTL-SDR voorbeeld)
echo "Installing RTL-SDR drivers..."
if [ "$OS" = "debian" ]; then
  sudo apt-get install -y rtl-sdr librtlsdr-dev
else
  sudo dnf install -y rtl-sdr rtl-sdr-devel
fi

# Compileer en installeer SoapyRTLSDR
if [ ! -d SoapyRTLSDR ]; then
  git clone https://github.com/pothosware/SoapyRTLSDR.git
fi
cd SoapyRTLSDR
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

# Check of SoapySDR de SDR hardware kan vinden
echo "Probing SDR hardware..."
SoapySDRUtil --probe

# Compileer en installeer SoapyRemote
if [ ! -d SoapyRemote ]; then
  git clone https://github.com/pothosware/SoapyRemote.git
fi
cd SoapyRemote
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

echo ""
echo "=== SoapyRemote Server Installatie Voltooid ==="
echo ""
echo "Start SoapyRemote server met:"
echo "  SoapySDRServer --bind"
echo ""
echo "Of bind naar een specifiek IP/poort:"
echo "  SoapySDRServer --bind=\"0.0.0.0:1234\""
echo ""
echo "Verbind vanaf een client met:"
echo "  SoapySDRUtil --probe=\"driver=remote,remote=tcp://<server-ip>:55132\""
