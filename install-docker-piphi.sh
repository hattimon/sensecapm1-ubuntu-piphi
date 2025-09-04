#!/bin/bash

# Docker and PiPhi Installation Script for Ubuntu Container
# Version: 1.4
# Author: hattimon (with assistance from Grok, xAI)
# Date: September 04, 2025, 05:30 AM CEST
# Description: Installs Docker and runs PiPhi Network Docker Compose inside the Ubuntu container, with USB GPS support, optimized for balenaEngine stability. Based on https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main.
# This script should be run inside the Ubuntu container after running install-piphi.sh on the host.

# Load or set language from temporary file
if [ -f /tmp/language ]; then
    LANGUAGE=$(cat /tmp/language)
else
    LANGUAGE="en"
fi

# Function to set language and save to temporary file
function set_language() {
    if [ "$LANGUAGE" = "en" ]; then
        LANGUAGE="pl"
        echo -e "Język zmieniony na polski."
        echo "pl" > /tmp/language
    else
        LANGUAGE="en"
        echo -e "Language changed to English."
        echo "en" > /tmp/language
    fi
}

# Translation arrays
declare -A MESSAGES
MESSAGES[pl,header]="Moduł: Instalacja Dockera i PiPhi w kontenerze Ubuntu"
MESSAGES[pl,separator]="================================================================"
MESSAGES[pl,update_system]="Aktualizacja systemu..."
MESSAGES[pl,install_deps]="Instalacja wymaganych zależności (w tym GPS)..."
MESSAGES[pl,add_gpg_key]="Dodawanie oficjalnego klucza GPG Dockera..."
MESSAGES[pl,set_repo]="Ustawianie repozytorium Dockera..."
MESSAGES[pl,install_docker]="Instalacja Dockera (tylko narzędzia klienckie)..."
MESSAGES[pl,verify_docker]="Weryfikacja instalacji Dockera..."
MESSAGES[pl,install_compose]="Instalacja pluginu Docker Compose..."
MESSAGES[pl,verify_compose]="Weryfikacja instalacji Docker Compose..."
MESSAGES[pl,navigate_dir]="Przejście do katalogu PiPhi Network Docker Compose..."
MESSAGES[pl,inspect_compose]="Sprawdzenie pliku Docker Compose..."
MESSAGES[pl,start_gpsd]="Uruchamianie usługi GPSD..."
MESSAGES[pl,check_resources]="Sprawdzanie dostępnych zasobów..."
MESSAGES[pl,restart_engine]="Restartowanie balenaEngine na hoście (jeśli potrzebne)..."
MESSAGES[pl,pull_images]="Pobieranie wymaganych obrazów Dockera (sekwencyjnie)..."
MESSAGES[pl,start_services]="Uruchamianie usług PiPhi Network..."
MESSAGES[pl,verify_containers]="Weryfikacja uruchomionych kontenerów..."
MESSAGES[pl,install_complete]="Instalacja Dockera i PiPhi zakończona! Panel PiPhi dostępny na http://<IP urządzenia>:31415"
MESSAGES[pl,grafana_access]="Dostęp do Grafana: http://<IP urządzenia>:3000"
MESSAGES[pl,gps_check]="Sprawdź GPS: cgps -s"
MESSAGES[pl,gps_note]="Uwaga: Umieść urządzenie na zewnątrz dla fix GPS (1–5 minut)."
MESSAGES[pl,install_cron]="Instalacja i konfiguracja crona..."

MESSAGES[en,header]="Module: Installing Docker and PiPhi in Ubuntu Container"
MESSAGES[en,separator]="================================================================"
MESSAGES[en,update_system]="Updating the system..."
MESSAGES[en,install_deps]="Installing required dependencies (including GPS)..."
MESSAGES[en,add_gpg_key]="Adding Docker’s Official GPG Key..."
MESSAGES[en,set_repo]="Setting Up the Docker Repository..."
MESSAGES[en,install_docker]="Installing Docker client tools only..."
MESSAGES[en,verify_docker]="Verifying Docker Installation..."
MESSAGES[en,install_compose]="Installing Docker Compose Plugin..."
MESSAGES[en,verify_compose]="Verifying Docker Compose Installation..."
MESSAGES[en,navigate_dir]="Navigating to the PiPhi Network Docker Compose Directory..."
MESSAGES[en,inspect_compose]="Inspecting the Docker Compose File..."
MESSAGES[en,start_gpsd]="Starting GPSD service..."
MESSAGES[en,check_resources]="Checking available resources..."
MESSAGES[en,restart_engine]="Restarting balenaEngine on host (if needed)..."
MESSAGES[en,pull_images]="Pulling Required Docker Images (sequentially)..."
MESSAGES[en,start_services]="Starting the PiPhi Network Services..."
MESSAGES[en,verify_containers]="Verifying Containers Are Running..."
MESSAGES[en,install_complete]="Docker and PiPhi installation completed! PiPhi panel available at http://<device IP>:31415"
MESSAGES[en,grafana_access]="Access Grafana: http://<device IP>:3000"
MESSAGES[en,gps_check]="Check GPS: cgps -s"
MESSAGES[en,gps_note]="Note: Place the device outdoors for GPS fix (1–5 minutes)."
MESSAGES[en,install_cron]="Installing and configuring cron..."

# Function to display message
function msg() {
    local key=$1
    printf "${MESSAGES[$LANGUAGE,$key]}\n" "${@:2}"
}

# Function to check resources
function check_resources() {
    local mem_total=$(free -m | grep Mem | awk '{print $2}')
    local mem_free=$(free -m | grep Mem | awk '{print $4}')
    if [ $((mem_free * 100 / mem_total)) -lt 20 ]; then
        msg "check_resources"
        echo "Warning: Low memory available. Consider stopping other containers or increasing resources."
        sleep 5
    fi
}

# Function to restart balenaEngine (via host)
function restart_engine() {
    msg "restart_engine"
    balena-engine stop >/dev/null 2>&1 || true
    balena-engine start >/dev/null 2>&1 || true
    sleep 10
}

# Installation function
function install() {
    msg "header"
    msg "separator"

    # Step 1: Update the System
    msg "update_system"
    apt-get update -y

    # Step 2: Install Required Dependencies including GPS support
    msg "install_deps"
    apt-get install -y apt-utils ca-certificates curl gnupg lsb-release usbutils gpsd gpsd-clients iputils-ping netcat-openbsd tzdata

    # Step 3: Add Docker’s Official GPG Key
    msg "add_gpg_key"
    mkdir -p /etc/apt/keyrings
    [ -f /etc/apt/keyrings/docker.gpg ] && rm /etc/apt/keyrings/docker.gpg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Step 4: Set Up the Docker Repository
    msg "set_repo"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Step 5: Install Docker client tools only (no daemon)
    msg "install_docker"
    apt-get update -y
    apt-get install -y docker-ce-cli

    # Step 6: Install Docker Compose Plugin
    msg "install_compose"
    apt-get install -y docker-compose-plugin

    # Step 7: Verify Docker Compose Installation
    msg "verify_compose"
    docker compose version

    # Step 8: Navigate to the PiPhi Network Docker Compose Directory
    msg "navigate_dir"
    cd /piphi-network || { echo "Error: Directory /piphi-network does not exist or is not mounted"; exit 1; }

    # Step 9: Inspect the Docker Compose File
    msg "inspect_compose"
    if [ -f docker-compose.yml ]; then
        cat docker-compose.yml
    else
        echo "Error: docker-compose.yml not found in /piphi-network. Ensure it is mounted from the host."
        exit 1
    fi

    # Step 10: Start GPSD service
    msg "start_gpsd"
    gpsd /dev/ttyACM0 -F /var/run/gpsd.sock

    # Step 11: Check resources before pulling
    check_resources

    # Step 12: Restart balenaEngine if needed
    if ! balena-engine info >/dev/null 2>&1; then
        restart_engine
    fi

    # Step 13: Pull Required Docker Images sequentially
    msg "pull_images"
    docker compose pull --parallel=1

    # Step 14: Start the PiPhi Network Services
    msg "start_services"
    docker compose up -d

    # Step 15: Verify Containers Are Running
    msg "verify_containers"
    docker compose ps

    # Step 16: Install and configure cron for automatic startup
    msg "install_cron"
    apt-get install -y cron
    crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull --parallel=1 && docker compose up -d && docker compose ps' | crontab -
    service cron start

    msg "install_complete"
    msg "grafana_access"
    msg "gps_check"
    msg "gps_note"
}

# Main menu
echo -e ""
msg "separator"
if [ "$LANGUAGE" = "pl" ]; then
    echo -e "Skrypt instalacyjny Dockera i PiPhi w kontenerze Ubuntu"
    echo -e "Wersja: 1.4 | Data: 04 września 2025, 05:30 CEST"
    echo -e "================================================================"
    echo -e "1 - Instalacja Dockera i PiPhi"
    echo -e "2 - Wyjście"
    echo -e "3 - Zmień na język Angielski"
else
    echo -e "Docker and PiPhi Installation Script for Ubuntu Container"
    echo -e "Version: 1.4 | Date: September 04, 2025, 05:30 AM CEST"
    echo -e "================================================================"
    echo -e "1 - Install Docker and PiPhi"
    echo -e "2 - Exit"
    echo -e "3 - Change to Polish language"
fi
msg "separator"
read -rp "Select an option and press ENTER: "
case "$REPLY" in
    1)
        clear
        sleep 1
        install
        ;;
    2)
        clear
        sleep 1
        exit
        ;;
    3)
        clear
        sleep 1
        set_language
        clear
        sleep 1
        # Recursive call to show updated menu
        . "$0"
        ;;
esac
