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

## Step 5: Install Docker Engine
```
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
```

## Step 6: Start Docker Daemon
```
nohup dockerd --host=unix:///var/run/docker.sock --storage-driver=vfs > /var/log/dockerd.log 2>&1 &
sleep 10
```

## Step 7: Verify Docker Installation
```
docker --version
```

## Step 8: Install Docker Compose Plugin
```
apt-get install -y docker-compose-plugin
```

## Step 9: Verify Docker Compose Installation
```
docker compose version
```

## Step 10: Navigate to the PiPhi Network Docker Compose Directory
```
cd /piphi-network
```

## Step 11: Inspect the Docker Compose File
```
cat docker-compose.yml
```

## Step 12: Pull Required Docker Images
```
docker compose pull
```

## Step 13: Start the PiPhi Network Services
```
docker compose up -d
```

## Step 14: Verify Containers Are Running
```
docker compose ps
```

## Step 15: Install cron for Automatic Startup
```
apt-get install -y cron
crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull && docker compose up -d && docker compose ps' | crontab -
```

## Step 16: Verify GPS Functionality
```
cgps -s
```
Note: Place the device outdoors for a GPS fix (1–5 minutes) if no signal is detected.

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

## Krok 5: Instalacja Silnika Dockera
```
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
```

## Krok 6: Uruchomienie Demona Dockera
```
nohup dockerd --host=unix:///var/run/docker.sock --storage-driver=vfs > /var/log/dockerd.log 2>&1 &
sleep 10
```

## Krok 7: Weryfikacja Instalacji Dockera
```
docker --version
```

## Krok 8: Instalacja Pluginu Docker Compose
```
apt-get install -y docker-compose-plugin
```

## Krok 9: Weryfikacja Instalacji Docker Compose
```
docker compose version
```

## Krok 10: Przejście do Katalogu PiPhi Network Docker Compose
```
cd /piphi-network
```

## Krok 11: Sprawdzenie Pliku Docker Compose
```
cat docker-compose.yml
```

## Krok 12: Pobranie Wymaganych Obrazów Dockera
```
docker compose pull
```

## Krok 13: Uruchomienie Usług PiPhi Network
```
docker compose up -d
```

## Krok 14: Weryfikacja Uruchomionych Kontenerów
```
docker compose ps
```

## Krok 15: Instalacja crona dla Automatycznego Uruchomienia
```
apt-get install -y cron
crontab -l 2>/dev/null; echo '@reboot sleep 60 && cd /piphi-network && docker compose pull && docker compose up -d && docker compose ps' | crontab -
```

## Krok 16: Weryfikacja Funkcjonalności GPS
```
cgps -s
```
Uwaga: Umieść urządzenie na zewnątrz dla fix GPS (1–5 minut), jeśli sygnał nie jest wykryty.
