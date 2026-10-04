#!/bin/bash
#
# SoapyRemote-server-installer — Install SoapySDR + SoapyRemote on Debian/Ubuntu/Fedora/RHEL
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
    error "Dit script moet worden uitgevoerd met sudo of als root."
fi

# Detect distro
if command -v apt-get &>/dev/null; then
    DISTRO="debian"
    INSTALL="apt-get install -y"
elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
    INSTALL="dnf install -y"
else
    error "Onbekende distro. Alleen Debian/Ubuntu en Fedora/RHEL worden ondersteund."
fi

log "Distro gedetecteerd: $DISTRO"

# Install build dependencies
log "Installeren van build dependencies..."
if [[ "$DISTRO" == "debian" ]]; then
    apt-get update -qq
    $INSTALL git gcc g++ make cmake
else
    $INSTALL git gcc gcc-c++ make cmake
fi

# Clone and build SoapySDR
if [[ ! -d SoapySDR ]]; then
    log "Clonen van SoapySDR..."
    git clone https://github.com/pothosware/SoapySDR.git
fi

cd SoapySDR
mkdir -p build
cd build
log "Compileren van SoapySDR..."
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

# Install SDR hardware drivers
log "Installeren van SDR hardware drivers..."
if [[ "$DISTRO" == "debian" ]]; then
    $INSTALL rtl-sdr librtlsdr-dev
else
    $INSTALL rtl-sdr rtl-sdr-devel
fi

# Clone and build SoapyRTLSDR
if [[ ! -d SoapyRTLSDR ]]; then
    log "Clonen van SoapyRTLSDR..."
    git clone https://github.com/pothosware/SoapyRTLSDR.git
fi

cd SoapyRTLSDR
mkdir -p build
cd build
log "Compileren van SoapyRTLSDR..."
cmake ..
make -j$(nproc)
sudo make install
cd ../..

# Check SoapySDR can find hardware
log "Controleren van SoapySDR hardware..."
SoapySDRUtil --probe || warn "Geen SDR hardware gevonden — dit is OK als je alleen de server wilt draaien."

# Clone and build SoapyRemote
if [[ ! -d SoapyRemote ]]; then
    log "Clonen van SoapyRemote..."
    git clone https://github.com/pothosware/SoapyRemote.git
fi

cd SoapyRemote
mkdir -p build
cd build
log "Compileren van SoapyRemote..."
cmake ..
make -j$(nproc)
sudo make install
cd ../..

# Start SoapyRemote server
log "Starten van SoapyRemote server..."
echo ""
log "Kies een optie:"
echo "  1) Bind to alle interfaces (standaard poort 55132)"
echo "  2) Bind naar specifiek IP en poort"
echo "  3) Afsluiten"
read -r -p "Keuze [1-3]: " choice

case $choice in
    1)
        SoapySDRServer --bind
        ;;
    2)
        read -r -p "IP:Poort (bijv. 0.0.0.0:1234): " bind
        SoapySDRServer --bind="$bind"
        ;;
    3)
        log "Afsluiten."
        exit 0
        ;;
    *)
        warn "Ongeldige keuze, standaard gebruikt."
        SoapySDRServer --bind
        ;;
esac
