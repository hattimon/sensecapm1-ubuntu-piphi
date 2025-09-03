#!/bin/bash

# Docker and PiPhi Installation Script for Ubuntu Container
# Version: 1.1
# Author: hattimon (with assistance from Grok, xAI)
# Date: September 03, 2025
# Description: Installs Docker and runs PiPhi Network Docker Compose inside the Ubuntu container. Based on https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main.
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
MESSAGES[pl,install_deps]="Instalacja wymaganych zależności..."
MESSAGES[pl,add_gpg_key]="Dodawanie oficjalnego klucza GPG Dockera..."
MESSAGES[pl,set_repo]="Ustawianie repozytorium Dockera..."
MESSAGES[pl,install_docker]="Instalacja Dockera..."
MESSAGES[pl,verify_docker]="Weryfikacja instalacji Dockera..."
MESSAGES[pl,install_compose]="Instalacja pluginu Docker Compose..."
MESSAGES[pl,verify_compose]="Weryfikacja instalacji Docker Compose..."
MESSAGES[pl,navigate_dir]="Przejście do katalogu PiPhi Network Docker Compose..."
MESSAGES[pl,inspect_compose]="Sprawdzenie pliku Docker Compose..."
MESSAGES[pl,pull_images]="Pobieranie wymaganych obrazów Dockera..."
MESSAGES[pl,start_services]="Uruchamianie usług PiPhi Network..."
MESSAGES[pl,verify_containers]="Weryfikacja uruchomionych kontenerów..."
MESSAGES[pl,install_complete]="Instalacja Dockera i PiPhi zakończona! Panel PiPhi dostępny na http://<IP urządzenia>:31415"
MESSAGES[pl,grafana_access]="Dostęp do Grafana: http://<IP urządzenia>:3000"
MESSAGES[pl,gps_check]="Sprawdź GPS: cgps -s"
MESSAGES[pl,gps_note]="Uwaga: Umieść urządzenie na zewnątrz dla fix GPS (1–5 minut)."

MESSAGES[en,header]="Module: Installing Docker and PiPhi in Ubuntu Container"
MESSAGES[en,separator]="================================================================"
MESSAGES[en,update_system]="Updating the system..."
MESSAGES[en,install_deps]="Installing required dependencies..."
MESSAGES[en,add_gpg_key]="Adding Docker’s Official GPG Key..."
MESSAGES[en,set_repo]="Setting Up the Docker Repository..."
MESSAGES[en,install_docker]="Installing Docker Engine..."
MESSAGES[en,verify_docker]="Verifying Docker Installation..."
MESSAGES[en,install_compose]="Installing Docker Compose Plugin..."
MESSAGES[en,verify_compose]="Verifying Docker Compose Installation..."
MESSAGES[en,navigate_dir]="Navigating to the PiPhi Network Docker Compose Directory..."
MESSAGES[en,inspect_compose]="Inspecting the Docker Compose File..."
MESSAGES[en,pull_images]="Pulling Required Docker Images..."
MESSAGES[en,start_services]="Starting the PiPhi Network Services..."
MESSAGES[en,verify_containers]="Verifying Containers Are Running..."
MESSAGES[en,install_complete]="Docker and PiPhi installation completed! PiPhi panel available at http://<device IP>:31415"
MESSAGES[en,grafana_access]="Access Grafana: http://<device IP>:3000"
MESSAGES[en,gps_check]="Check GPS: cgps -s"
MESSAGES[en,gps_note]="Note: Place the device outdoors for GPS fix (1–5 minutes)."

# Function to display message
function msg() {
    local key=$1
    printf "${MESSAGES[$LANGUAGE,$key]}\n" "${@:2}"
}

# Installation function
function install() {
    msg "header"
    msg "separator"

    # Step 1: Update the System
    msg "update_system"
    apt-get update -y

    # Step 2: Install Required Dependencies
    msg "install_deps"
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Step 3: Add Docker’s Official GPG Key
    msg "add_gpg_key"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Step 4: Set Up the Docker Repository
    msg "set_repo"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Step 5: Install Docker Engine
    msg "install_docker"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Step 6: Verify Docker Installation
    msg "verify_docker"
    docker --version

    # Step 7: Install Docker Compose Plugin
    msg "install_compose"
    apt-get install -y docker-compose-plugin

    # Step 8: Verify Docker Compose Installation
    msg "verify_compose"
    docker compose version

    # Step 9: Navigate to the PiPhi Network Docker Compose Directory
    msg "navigate_dir"
    cd /piphi-network || { echo "Error: Directory /piphi-network does not exist"; exit 1; }

    # Step 10: Inspect the Docker Compose File
    msg "inspect_compose"
    cat docker-compose.yml

    # Step 11: Pull Required Docker Images
    msg "pull_images"
    docker compose pull

    # Step 12: Start the PiPhi Network Services
    msg "start_services"
    docker compose up -d

    # Step 13: Verify Containers Are Running
    msg "verify_containers"
    docker compose ps

    # Add cron for automatic startup with delay to avoid conflicts
    crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull && docker compose up -d && docker compose ps' | crontab -

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
    echo -e "Wersja: 1.1 | Data: 03 września 2025"
    echo -e "================================================================"
    echo -e "1 - Instalacja Dockera i PiPhi"
    echo -e "2 - Wyjście"
    echo -e "3 - Zmień na język Angielski"
else
    echo -e "Docker and PiPhi Installation Script for Ubuntu Container"
    echo -e "Version: 1.1 | Date: September 03, 2025"
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
