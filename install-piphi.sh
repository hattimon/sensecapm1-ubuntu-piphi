#!/bin/bash

# PiPhi Network Installation Script for SenseCAP M1 with balenaOS
# Version: 2.29
# Author: hattimon (with assistance from Grok, xAI)
# Date: September 03, 2025, 11:56 PM CEST
# Description: Installs the Ubuntu container for PiPhi Network alongside Helium Miner, with GPS dongle (U-Blox 7) support and automatic startup on reboot. Based on https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main.

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
MESSAGES[pl,header]="Moduł: Instalacja kontenera Ubuntu dla PiPhi Network"
MESSAGES[pl,separator]="================================================================"
MESSAGES[pl,wget_missing]="Wget nie jest zainstalowany. Zainstaluj wget lub pobierz pliki ręcznie via scp."
MESSAGES[pl,changing_dir]="Zmiana katalogu na /mnt/data/piphi-network..."
MESSAGES[pl,dir_error]="Nie można zmienić katalogu na /mnt/data/piphi-network"
MESSAGES[pl,checking_helium]="Sprawdzanie kontenerów Helium..."
MESSAGES[pl,helium_not_found]="Nie znaleziono kontenera Helium (pktfwd_). Sprawdź konfigurację SenseCAP M1."
MESSAGES[pl,helium_found]="Znaleziono kontener Helium: %s"
MESSAGES[pl,loading_gps]="Ładowanie modułu GPS (cdc-acm) na hoście..."
MESSAGES[pl,gps_detected]="GPS wykryty: %s"
MESSAGES[pl,gps_not_detected]="GPS nie wykryty. Sprawdź podłączenie U-Blox 7 i uruchom 'lsusb'."
MESSAGES[pl,removing_old]="Usuwanie istniejących instalacji (kontenerów i danych), jeśli istnieją..."
MESSAGES[pl,downloading_compose]="Pobieranie docker-compose.yml..."
MESSAGES[pl,download_error]="Błąd pobierania docker-compose.yml"
MESSAGES[pl,verifying_compose]="Weryfikacja pobranego pliku docker-compose.yml..."
MESSAGES[pl,compose_invalid]="Pobrany plik docker-compose.yml jest nieprawidłowy lub nie zawiera usługi 'software'. Używanie domyślnego pliku."
MESSAGES[pl,checking_network]="Sprawdzanie połączenia sieciowego..."
MESSAGES[pl,network_error]="Błąd połączenia z Docker Hub. Ponawianie..."
MESSAGES[pl,setting_dns]="Ustawianie DNS na Google (8.8.8.8) w kontenerze..."
MESSAGES[pl,dns_error]="Błąd ustawiania DNS w kontenerze. Sprawdź logi: balena logs ubuntu-piphi"
MESSAGES[pl,pulling_ubuntu]="Pobieranie obrazu Ubuntu (próba %d/3)..."
MESSAGES[pl,pull_error]="Błąd pobierania obrazu Ubuntu po 3 próbach"
MESSAGES[pl,running_container]="Uruchamianie kontenera Ubuntu z PiPhi..."
MESSAGES[pl,run_error]="Błąd uruchamiania kontenera Ubuntu. Sprawdź logi: balena logs ubuntu-piphi"
MESSAGES[pl,waiting_container]="Czekanie na uruchomienie kontenera Ubuntu (maks. 60 sekund)..."
MESSAGES[pl,waiting_container_progress]="Czekanie na kontener Ubuntu... (%ds sekund)"
MESSAGES[pl,container_failed]="Kontener ubuntu-piphi nie osiągnął stanu Up. Sprawdź logi: balena logs ubuntu-piphi"
MESSAGES[pl,install_complete]="Instalacja kontenera Ubuntu zakończona! Uruchom install-docker-piphi.sh, aby kontynuować."

MESSAGES[en,header]="Module: Installing Ubuntu Container for PiPhi Network"
MESSAGES[en,separator]="================================================================"
MESSAGES[en,wget_missing]="Wget is not installed. Install wget or download files manually via scp."
MESSAGES[en,changing_dir]="Changing directory to /mnt/data/piphi-network..."
MESSAGES[en,dir_error]="Cannot change directory to /mnt/data/piphi-network"
MESSAGES[en,checking_helium]="Checking Helium containers..."
MESSAGES[en,helium_not_found]="No Helium container (pktfwd_) found. Check SenseCAP M1 configuration."
MESSAGES[en,helium_found]="Found Helium container: %s"
MESSAGES[en,loading_gps]="Loading GPS module (cdc-acm) on the host..."
MESSAGES[en,gps_detected]="GPS detected: %s"
MESSAGES[en,gps_not_detected]="GPS not detected. Check U-Blox 7 connection and run 'lsusb'."
MESSAGES[en,removing_old]="Removing existing installations (containers and data) if they exist..."
MESSAGES[en,downloading_compose]="Downloading docker-compose.yml..."
MESSAGES[en,download_error]="Error downloading docker-compose.yml"
MESSAGES[en,verifying_compose]="Verifying downloaded docker-compose.yml..."
MESSAGES[en,compose_invalid]="Downloaded docker-compose.yml is invalid or does not contain 'software' service. Using default file."
MESSAGES[en,checking_network]="Checking network connectivity..."
MESSAGES[en,network_error]="Error connecting to Docker Hub. Retrying..."
MESSAGES[en,setting_dns]="Setting DNS to Google (8.8.8.8) in container..."
MESSAGES[en,dns_error]="Error setting DNS in container. Check logs: balena logs ubuntu-piphi"
MESSAGES[en,pulling_ubuntu]="Pulling Ubuntu image (attempt %d/3)..."
MESSAGES[en,pull_error]="Error pulling Ubuntu image after 3 attempts"
MESSAGES[en,running_container]="Running Ubuntu container with PiPhi..."
MESSAGES[en,run_error]="Error running Ubuntu container. Check logs: balena logs ubuntu-piphi"
MESSAGES[en,waiting_container]="Waiting for Ubuntu container to start (max 60 seconds)..."
MESSAGES[en,waiting_container_progress]="Waiting for Ubuntu container... (%ds seconds)"
MESSAGES[en,container_failed]="Container ubuntu-piphi failed to reach Up state. Check logs: balena logs ubuntu-piphi"
MESSAGES[en,install_complete]="Ubuntu container installation completed! Run install-docker-piphi.sh to continue."

# Function to display message
function msg() {
    local key=$1
    printf "${MESSAGES[$LANGUAGE,$key]}\n" "${@:2}"
}

# Function to wait for container to be in "Up" state
function wait_for_container() {
    local container_name=$1
    local max_wait=$2
    local attempt
    for attempt in $(seq 1 $((max_wait/5))); do
        if balena ps -a | grep "$container_name" | grep -q "Up"; then
            sleep 5  # Additional delay to ensure container is fully stable
            return 0
        fi
        msg "waiting_container_progress" $((attempt*5))
        sleep 5
    done
    msg "container_failed"
    balena logs "$container_name"
    exit 1
}

# Function to execute command with retries
function exec_with_retry() {
    local cmd=$1
    local max_attempts=3
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if balena exec -t ubuntu-piphi bash -c "$cmd 2>&1 | tee /tmp/apt.log"; then
            return 0
        fi
        msg "waiting_container_progress" $((attempt*5))
        sleep 5
        attempt=$((attempt+1))
    done
    balena exec -t ubuntu-piphi cat /tmp/apt.log
    return 1
}

# Installation function
function install() {
    msg "header"
    msg "separator"

    # Check for wget availability (on host)
    if ! command -v wget >/dev/null 2>&1; then
        msg "wget_missing"
        exit 1
    fi

    # Change directory to /mnt/data (writable, on host)
    msg "changing_dir"
    mkdir -p /mnt/data/piphi-network
    cd /mnt/data/piphi-network || {
        msg "dir_error"
        exit 1
    }

    # Check for existing Helium containers (on host)
    msg "checking_helium"
    balena ps
    local helium_container=$(balena ps --format "{{.Names}}" | grep pktfwd_ || true)
    if [ -z "$helium_container" ]; then
        msg "helium_not_found"
        exit 1
    fi
    msg "helium_found" "$helium_container"

    # Load GPS module (U-Blox 7) on the host
    msg "loading_gps"
    modprobe cdc-acm
    if ls /dev/ttyACM* >/dev/null 2>&1; then
        msg "gps_detected" "$(ls /dev/ttyACM*)"
    else
        msg "gps_not_detected"
        exit 1
    fi

    # Remove existing installations to avoid conflicts (on host)
    msg "removing_old"
    balena stop ubuntu-piphi 2>/dev/null || true
    balena rm ubuntu-piphi 2>/dev/null || true
    rm -rf /mnt/data/piphi-network/* 2>/dev/null || true

    # Download docker-compose.yml from PiPhi link (on host)
    msg "downloading_compose"
    wget -O docker-compose.yml https://chibisafe.piphi.network/m2JmK11Z7tor.yml || {
        msg "download_error"
        exit 1
    }

    # Verify and update docker-compose.yml (on host)
    msg "verifying_compose"
    if ! grep -q "services:" docker-compose.yml || ! grep -q "software:" docker-compose.yml; then
        msg "compose_invalid"
        cat > docker-compose.yml << EOL
version: '3.3'
services:
  db:
    container_name: db
    image: postgres:13.3
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=piphi31415
      - POSTGRES_DB=postgres
      - POSTGRES_NAME=postgres
    ports:
      - '5432:5432'
    volumes:
      - db:/var/lib/postgresql/data
      - /etc/localtime:/etc/localtime:ro
    network_mode: host
  software:
    container_name: piphi-network-image
    restart: on-failure
    pull_policy: always
    image: piphinetwork/team-piphi:latest
    ports:
      - '31415:31415'
    depends_on:
      - db
    privileged: true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/dbus:/var/run/dbus
    devices:
      - "/dev/ttyACM0:/dev/ttyACM0"
    environment:
      - "GPS_DEVICE=/dev/ttyACM0"
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    network_mode: host
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: always
    command: --interval 300
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - WATCHTOWER_INCLUDE_RESTARTING=true
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    network_mode: host
  grafana:
    container_name: grafana
    image: grafana/grafana-oss
    ports:
      - "3000:3000"
    volumes:
      - grafana:/var/lib/grafana
    restart: unless-stopped
volumes:
  db:
    driver: local
  grafana:
    driver: local
EOL
    else
        sed -i '/^version:/d' docker-compose.yml
    fi

    # Check network connectivity before pulling image (on host)
    msg "checking_network"
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        msg "network_error"
        exit 1
    fi

    # Pull Ubuntu image with retries (on host)
    msg "pulling_ubuntu" 1
    local attempt
    for attempt in {1..3}; do
        if balena pull ubuntu:20.04; then
            break
        fi
        if [ $attempt -lt 3 ]; then
            msg "network_error"
            msg "pulling_ubuntu" $((attempt+1))
            sleep 5
        else
            msg "pull_error"
            exit 1
        fi
    done

    # Run Ubuntu container with minimal startup command (on host)
    msg "running_container"
    balena run -d --privileged -v /mnt/data/piphi-network:/piphi-network -p 31415:31415 -p 5432:5432 -p 3000:3000 --cpus="2.0" --memory="2g" --name ubuntu-piphi --restart unless-stopped ubuntu:20.04 /bin/bash -c "while true; do sleep 3600; done" || {
        msg "run_error"
        balena logs ubuntu-piphi
        exit 1
    }

    # Wait for the container to fully start (on host)
    msg "waiting_container"
    if ! wait_for_container "ubuntu-piphi" 60; then
        msg "container_failed"
        balena logs ubuntu-piphi
        exit 1
    fi

    # Set DNS inside the container
    msg "setting_dns"
    exec_with_retry "echo 'nameserver 8.8.8.8' > /etc/resolv.conf" || {
        msg "dns_error"
        balena logs ubuntu-piphi
        exit 1
    }

    # Preconfigure tzdata to avoid interactive prompts
    msg "installing_deps"
    exec_with_retry "echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections" || {
        msg "deps_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "echo 'tzdata tzdata/Zones/Europe select Warsaw' | debconf-set-selections" || {
        msg "deps_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "export DEBIAN_FRONTEND=noninteractive && apt-get update" || {
        msg "deps_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "export DEBIAN_FRONTEND=noninteractive && apt-get install -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" ca-certificates curl gnupg lsb-release usbutils gpsd gpsd-clients iputils-ping tzdata" || {
        msg "deps_error"
        balena logs ubuntu-piphi
        exit 1
    }

    msg "installing_yq"
    exec_with_retry "curl -L https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_arm64 -o /usr/bin/yq && chmod +x /usr/bin/yq" || {
        msg "yq_error"
        balena logs ubuntu-piphi
        exit 1
    }

    msg "configuring_repo"
    exec_with_retry "mkdir -p /etc/apt/keyrings" || {
        msg "repo_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "rm -f /etc/apt/sources.list.d/docker.list" || {
        msg "repo_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" || {
        msg "repo_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "echo \"deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu focal stable\" > /etc/apt/sources.list.d/docker.list" || {
        msg "repo_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "export DEBIAN_FRONTEND=noninteractive && apt-get update" || {
        msg "repo_error"
        balena logs ubuntu-piphi
        exit 1
    }

    msg "installing_docker"
    exec_with_retry "export DEBIAN_FRONTEND=noninteractive && apt-get install -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" docker-ce docker-ce-cli containerd.io docker-compose-plugin" || {
        msg "docker_error"
        balena logs ubuntu-piphi
        exit 1
    }

    # Create startup script for Docker daemon (in container, but not executed here to avoid loop)
    msg "configuring_daemon"
    exec_with_retry "cat > /piphi-network/start-docker.sh << EOL
#!/bin/bash
# Prevent daemon loop by checking if dockerd is already running
if ! pgrep dockerd > /dev/null; then
    nohup dockerd --host=unix:///var/run/docker.sock --storage-driver=vfs > /piphi-network/dockerd.log 2>&1 &
    sleep 10
fi
cd /piphi-network && docker compose pull
sleep 5
cd /piphi-network && docker compose up -d
EOL" || {
        msg "run_error"
        balena logs ubuntu-piphi
        exit 1
    }
    exec_with_retry "chmod +x /piphi-network/start-docker.sh" || {
        msg "run_error"
        balena logs ubuntu-piphi
        exit 1
    }

    msg "install_complete"
}

# Main menu
echo -e ""
msg "separator"
if [ "$LANGUAGE" = "pl" ]; then
    echo -e "Skrypt instalacyjny PiPhi Network na SenseCAP M1 z balenaOS"
    echo -e "Wersja: 2.29 | Data: 03 września 2025, 23:56 CEST"
    echo -e "================================================================"
    echo -e "1 - Instalacja kontenera Ubuntu dla PiPhi Network"
    echo -e "2 - Wyjście"
    echo -e "3 - Zmień na język Angielski"
else
    echo -e "PiPhi Network Installation Script for SenseCAP M1 with balenaOS"
    echo -e "Version: 2.29 | Date: September 03, 2025, 11:56 PM CEST"
    echo -e "================================================================"
    echo -e "1 - Install Ubuntu Container for PiPhi Network"
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
