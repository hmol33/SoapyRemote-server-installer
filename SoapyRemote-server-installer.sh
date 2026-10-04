#!/bin/bash
set -euo pipefail

# SoapyRemote-server-installer — Verbeterde versie
# Installert SoapyRemote server op Debian/Ubuntu/Fedora/RHEL

# ─── Configuratie ──────────────────────────────────────────────────────────────
DRY_RUN="${DRY_RUN:-}"
LOG_FILE="${LOG_FILE:-/tmp/soapyremote-installer.log}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/soapyremote-install}"

# ─── Logging ──────────────────────────────────────────────────────────────────
log() {
    local level="$1"
    shift
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

info()  { log "INFO" "$@"; }
warn()  { log "WARN" "$@"; }
error() { log "ERROR" "$@"; }

# ─── DRY_RUN helper ───────────────────────────────────────────────────────────
run() {
    if [ -n "$DRY_RUN" ]; then
        info "[DRY-RUN] Would run: $*"
        return 0
    fi
    "$@"
}

# ─── OS detectie ──────────────────────────────────────────────────────────────
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# ─── Dependency check ─────────────────────────────────────────────────────────
check_dependencies() {
    local deps=("git" "cmake" "make" "gcc" "g++")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Ontbrekende dependencies: ${missing[*]}"
        exit 1
    fi
    
    info "Alle dependencies aanwezig"
}

# ─── Error handler ────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "Installatie mislukt met exit code $exit_code"
        error "Bekijk log: $LOG_FILE"
    fi
    exit $exit_code
}
trap cleanup EXIT

# ─── Hoofdinstallatie ─────────────────────────────────────────────────────────
main() {
    local os
    os=$(detect_os)
    
    info "=== SoapyRemote Installer gestart ==="
    info "Gedetecteerd OS: $os"
    info "Installatie directory: $INSTALL_DIR"
    info "Log bestand: $LOG_FILE"
    
    if [ -n "$DRY_RUN" ]; then
        info "DRY-RUN mode — er worden geen wijzigingen aangebracht"
    fi
    
    check_dependencies
    
    # Stap 1: Installeer systeem dependencies
    info "Stap 1/6: Systeem dependencies installeren"
    case "$os" in
        ubuntu|debian)
            run sudo apt-get update -qq
            run sudo apt-get install -y -qq git gcc g++ make cmake rtl-sdr librtlsdr-dev
            ;;
        fedora)
            run sudo dnf install -y -q git gcc gcc-c++ make cmake rtl-sdr rtl-sdr-devel
            ;;
        rhel|centos)
            run sudo yum install -y -q git gcc gcc-c++ make cmake rtl-sdr rtl-sdr-devel
            ;;
        *)
            warn "Onbekend OS: $os — probeer Debian/Ubuntu dependencies"
            run sudo apt-get update -qq
            run sudo apt-get install -y -qq git gcc g++ make cmake rtl-sdr librtlsdr-dev
            ;;
    esac
    
    # Stap 2: Maak installatie directory
    info "Stap 2/6: Installatie directory voorbereiden"
    if [ ! -d "$INSTALL_DIR" ]; then
        run mkdir -p "$INSTALL_DIR"
    fi
    cd "$INSTALL_DIR"
    
    # Stap 3: Clone en bouw SoapySDR
    info "Stap 3/6: SoapySDR bouwen"
    if [ ! -d "SoapySDR" ]; then
        run git clone https://github.com/pothosware/SoapySDR.git
    fi
    cd SoapySDR
    if [ ! -d "build" ]; then
        run mkdir build
    fi
    cd build
    run cmake ..
    run make -j"$(nproc)"
    run sudo make install
    run sudo ldconfig
    cd "$INSTALL_DIR"
    
    # Stap 4: Clone en bouw SoapyRTLSDR
    info "Stap 4/6: SoapyRTLSDR bouwen"
    if [ ! -d "SoapyRTLSDR" ]; then
        run git clone https://github.com/pothosware/SoapyRTLSDR.git
    fi
    cd SoapyRTLSDR
    if [ ! -d "build" ]; then
        run mkdir build
    fi
    cd build
    run cmake ..
    run make -j"$(nproc)"
    run sudo make install
    run sudo ldconfig
    cd "$INSTALL_DIR"
    
    # Stap 5: Clone en bouw SoapyRemote
    info "Stap 5/6: SoapyRemote bouwen"
    if [ ! -d "SoapyRemote" ]; then
        run git clone https://github.com/pothosware/SoapyRemote.git
    fi
    cd SoapyRemote
    if [ ! -d "build" ]; then
        run mkdir build
    fi
    cd build
    run cmake ..
    run make -j"$(nproc)"
    run sudo make install
    run sudo ldconfig
    cd "$INSTALL_DIR"
    
    # Stap 6: Verifieer installatie
    info "Stap 6/6: Installatie verifiëren"
    if command -v SoapySDRUtil &>/dev/null; then
        info "SoapySDRUtil gevonden — probeer je SDR:"
        info "  SoapySDRUtil --probe"
    else
        warn "SoapySDRUtil niet gevonden in PATH — mogelijk moet je nog een keer inloggen"
    fi
    
    info "=== Installatie voltooid ==="
    info "SoapyRemote is geïnstalleerd in $INSTALL_DIR"
    info "Start met: SoapySDRServer --bind"
    info "Bind to a specific IP: SoapySDRServer --bind=\"0.0.0.0:1234\""
}

main "$@"
