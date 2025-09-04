# Manual Installation Guide (English)

Based on [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main).

## Prerequisites
- Ensure `wget` is installed on the host: `apt-get install -y wget`
- Connect a USB GPS dongle (e.g., U-Blox 7) to the SenseCAP M1.

## Step 1: Update the System
```
apt-get update
apt-get upgrade -y
```

## Step 2: Install Required Dependencies (including GPS support)
```
apt-get install -y apt-utils ca-certificates curl gnupg lsb-release usbutils gpsd gpsd-clients iputils-ping netcat-openbsd tzdata
```

## Step 3: Add Docker’s Official GPG Key
```
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

## Step 4: Set Up the Docker Repository
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## Step 5: Install Docker Client Tools
```
apt-get update
apt-get install -y docker-ce-cli
```

## Step 6: Install Docker Compose Plugin
```
apt-get install -y docker-compose-plugin
```

## Step 7: Verify Docker Compose Installation
```
docker compose version
```

## Step 8: Navigate to the PiPhi Network Docker Compose Directory
```
cd /piphi-network
```

## Step 9: Inspect the Docker Compose File
```
cat docker-compose.yml
```

## Step 10: Start GPSD Service
```
gpsd /dev/ttyACM0 -F /var/run/gpsd.sock
```

## Step 11: Pull Required Docker Images (Single Pull)
```
docker compose pull postgres:13.3
docker compose pull containrrr/watchtower
docker compose pull grafana/grafana-oss
docker compose pull piphinetwork/team-piphi:latest
```

## Step 12: Start the PiPhi Network Services
```
docker compose up -d
```

## Step 13: Verify Containers Are Running
```
docker compose ps
```

## Step 14: Install cron for Automatic Startup
```
apt-get install -y cron
crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull postgres:13.3 && docker compose pull containrrr/watchtower && docker compose pull grafana/grafana-oss && docker compose pull piphinetwork/team-piphi:latest && docker compose up -d && docker compose ps' | crontab -
service cron start
```

## Step 15: Verify GPS Functionality
```
cgps -s
```
Note: Place the device outdoors for a GPS fix (1–5 minutes) if no signal is detected.

## Run PiPhi Container with Resource Limits
To start the `ubuntu-piphi` container with 1 CPU and 2 GB memory on balenaOS host, use:
```
balena run -d --privileged -v /mnt/data/piphi-network:/piphi-network -p 31415:31415 -p 5432:5432 -p 3000:3000 --cpus="1.0" --memory="2g" --name ubuntu-piphi --restart unless-stopped ubuntu:20.04 /bin/bash -c "while true; do sleep 3600; done"
```

# Podręcznik Instalacji Ręcznej (Polski)

Oparte na [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main).

## Wymagania wstępne
- Upewnij się, że `wget` jest zainstalowany na hoście: `apt-get install -y wget`
- Podłącz dongle USB GPS (np. U-Blox 7) do SenseCAP M1.

## Krok 1: Aktualizacja Systemu
```
apt-get update
apt-get upgrade -y
```

## Krok 2: Instalacja Wymaganych Zależności (w tym obsługa GPS)
```
apt-get install -y apt-utils ca-certificates curl gnupg lsb-release usbutils gpsd gpsd-clients iputils-ping netcat-openbsd tzdata
```

## Krok 3: Dodanie Oficjalnego Klucza GPG Dockera
```
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

## Krok 4: Ustawienie Repozytorium Dockera
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## Krok 5: Instalacja Narzędzi Klienta Dockera
```
apt-get update
apt-get install -y docker-ce-cli
```

## Krok 6: Instalacja Pluginu Docker Compose
```
apt-get install -y docker-compose-plugin
```

## Krok 7: Weryfikacja Instalacji Docker Compose
```
docker compose version
```

## Krok 8: Przejście do Katalogu PiPhi Network Docker Compose
```
cd /piphi-network
```

## Krok 9: Sprawdzenie Pliku Docker Compose
```
cat docker-compose.yml
```

## Krok 10: Uruchomienie Usługi GPSD
```
gpsd /dev/ttyACM0 -F /var/run/gpsd.sock
```

## Krok 11: Pobranie Wymaganych Obrazów Dockera (Pojedynczo)
```
docker compose pull postgres:13.3
docker compose pull containrrr/watchtower
docker compose pull grafana/grafana-oss
docker compose pull piphinetwork/team-piphi:latest
```

## Krok 12: Uruchomienie Usług PiPhi Network
```
docker compose up -d
```

## Krok 13: Weryfikacja Uruchomionych Kontenerów
```
docker compose ps
```

## Krok 14: Instalacja crona dla Automatycznego Uruchomienia
```
apt-get install -y cron
crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull postgres:13.3 && docker compose pull containrrr/watchtower && docker compose pull grafana/grafana-oss && docker compose pull piphinetwork/team-piphi:latest && docker compose up -d && docker compose ps' | crontab -
service cron start
```

## Krok 15: Weryfikacja Funkcjonalności GPS
```
cgps -s
```
Uwaga: Umieść urządzenie na zewnątrz dla fix GPS (1–5 minut), jeśli sygnał nie jest wykryty.

## Uruchomienie Kontenera PiPhi z Ograniczeniami Zasobów
Aby uruchomić kontener `ubuntu-piphi` z 1 procesorem i 2 GB pamięci na hoście balenaOS, użyj:
```
balena run -d --privileged -v /mnt/data/piphi-network:/piphi-network -p 31415:31415 -p 5432:5432 -p 3000:3000 --cpus="1.0" --memory="2g" --name ubuntu-piphi --restart unless-stopped ubuntu:20.04 /bin/bash -c "while true; do sleep 3600; done"
```
