# Manual Installation Guide (English)

## Step 1: Update the System
```
apt-get update
apt-get upgrade -y
```

## Step 2: Install Required Dependencies
```
apt-get install -y ca-certificates curl gnupg lsb-release
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

## Step 6: Verify Docker Installation
```
docker --version
```

## Step 7: Install Docker Compose Plugin
```
apt-get install -y docker-compose-plugin
```

## Step 8: Verify Docker Compose Installation
```
docker compose version
```

## Step 9: Navigate to the PiPhi Network Docker Compose Directory
```
cd /piphi-network
```

## Step 10: Inspect the Docker Compose File
```
cat docker-compose.yml
```

## Step 11: Pull Required Docker Images
```
docker compose pull
```

## Step 12: Start the PiPhi Network Services
```
docker compose up -d
```

## Step 13: Verify Containers Are Running
```
docker compose ps
```

# Podręcznik Instalacji Ręcznej (Polski)

## Krok 1: Aktualizacja Systemu
```
apt-get update
apt-get upgrade -y
```

## Krok 2: Instalacja Wymaganych Zależności
```
apt-get install -y ca-certificates curl gnupg lsb-release
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

## Krok 6: Weryfikacja Instalacji Dockera
```
docker --version
```

## Krok 7: Instalacja Pluginu Docker Compose
```
apt-get install -y docker-compose-plugin
```

## Krok 8: Weryfikacja Instalacji Docker Compose
```
docker compose version
```

## Krok 9: Przejście do Katalogu PiPhi Network Docker Compose
```
cd /piphi-network
```

## Krok 10: Sprawdzenie Pliku Docker Compose
```
cat docker-compose.yml
```

## Krok 11: Pobranie Wymaganych Obrazów Dockera
```
docker compose pull
```

## Krok 12: Uruchomienie Usług PiPhi Network
```
docker compose up -d
```

## Krok 13: Weryfikacja Uruchomionych Kontenerów
```
docker compose ps
```
