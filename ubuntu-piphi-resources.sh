```bash
#!/bin/bash

# Skrypt: ubuntu-piphi-resources.sh
# Cel: Zmiana CPU i RAM kontenera ubuntu-piphi w BalenaOS, zachowanie danych i automatyczny restart
# Współdzielony plik konfiguracyjny: /mnt/data/.ubuntu_piphi_config
# Domyślny język: Polski
# Data: 04 września 2025

CONFIG_FILE="/mnt/data/.ubuntu_piphi_config"
CONTAINER_NAME="ubuntu-piphi"
HOST_VOLUME="/mnt/data/piphi-network"
CONTAINER_VOLUME="/piphi-network"
IMAGE="ubuntu:20.04"

# Sprawdzenie, czy balena jest dostępna
if ! command -v balena >/dev/null 2>&1; then
    echo "Błąd: Komenda balena nie jest dostępna. Upewnij się, że działasz w środowisku balenaOS."
    exit 1
fi

# Sprawdzenie, czy daemon Docker działa
if ! balena ps >/dev/null 2>&1; then
    echo "Błąd: Nie można połączyć się z daemona Docker. Sprawdź, czy działa: systemctl status docker"
    echo "Sprawdź również, czy /var/run/docker.sock istnieje: ls -l /var/run/docker.sock"
    exit 1
fi

# -----------------------
# Funkcje językowe
# -----------------------
choose_language() {
    echo "Wybierz język:"
    echo "1) English"
    echo "2) Polski (domyślny)"
    read -p "Wybór [2]: " LANG_CHOICE
    case "$LANG_CHOICE" in
        1) LANG="EN" ;;
        *) LANG="PL" ;;
    esac
    # Zapisz język do pliku tymczasowego dla spójności z install-piphi.sh
    echo "$LANG" > /tmp/language || {
        echo "Błąd: Nie można zapisać języka do /tmp/language"
        exit 1
    }
}

# Funkcja do wyświetlania komunikatów w wybranym języku
msg() {
    if [ "$LANG" = "PL" ]; then
        case $1 in
            cpu_prompt) echo -n "Podaj liczbę rdzeni CPU dla kontenera [$CPU_LIMIT]: " ;;
            ram_prompt) echo -n "Podaj ilość RAM dla kontenera (np. 2 dla 2GB) [$RAM_LIMIT]: " ;;
            removing) echo "Kontener ${CONTAINER_NAME} już istnieje. Usuwam..." ;;
            starting) echo "Uruchamianie kontenera ${CONTAINER_NAME} z CPU=${CPU_LIMIT} RAM=${RAM_LIMIT}g..." ;;
            finished) echo "Kontener uruchomiony. Możesz wejść do niego poleceniem:" ;;
            error_config) echo "Błąd: Nie można zapisać pliku konfiguracyjnego $CONFIG_FILE" ;;
            error_container) echo "Błąd: Kontener ${CONTAINER_NAME} nie został uruchomiony. Sprawdź logi: balena logs ${CONTAINER_NAME}" ;;
        esac
    else
        case $1 in
            cpu_prompt) echo -n "Enter number of CPU cores for the container [$CPU_LIMIT]: " ;;
            ram_prompt) echo -n "Enter amount of RAM for the container (e.g., 2 for 2GB) [$RAM_LIMIT]: " ;;
            removing) echo "Container ${CONTAINER_NAME} already exists. Removing..." ;;
            starting) echo "Starting container ${CONTAINER_NAME} with CPU=${CPU_LIMIT} RAM=${RAM_LIMIT}g..." ;;
            finished) echo "Container started. You can access it with:" ;;
            error_config) echo "Error: Could not write to configuration file $CONFIG_FILE" ;;
            error_container) echo "Error: Container ${CONTAINER_NAME} failed to start. Check logs: balena logs ${CONTAINER_NAME}" ;;
        esac
    fi
}

# -----------------------
# Funkcje konfiguracji
# -----------------------
load_last_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        CPU_LIMIT="2.0"  # Domyślna wartość zgodna z install-piphi.sh
        RAM_LIMIT="2"    # Domyślna wartość zgodna z install-piphi.sh
    fi
}

save_config() {
    echo "CPU_LIMIT=\"$CPU_LIMIT\"" > "$CONFIG_FILE" || { msg error_config; exit 1; }
    echo "RAM_LIMIT=\"$RAM_LIMIT\"" >> "$CONFIG_FILE" || { msg error_config; exit 1; }
}

# -----------------------
# Główny skrypt
# -----------------------
# Wczytaj język z pliku tymczasowego, jeśli istnieje
if [ -f /tmp/language ]; then
    LANG=$(cat /tmp/language)
else
    LANG="PL"
fi

# Pozwól użytkownikowi zmienić język, jeśli chce
choose_language
load_last_config

# Pobranie parametrów od użytkownika (z domyślnymi wartościami)
msg cpu_prompt
read CPU_INPUT
CPU_LIMIT=${CPU_INPUT:-$CPU_LIMIT}

msg ram_prompt
read RAM_INPUT
RAM_LIMIT=${RAM_INPUT:-$RAM_LIMIT}

# Zapisz konfigurację
save_config

# Sprawdzenie czy kontener istnieje
if balena ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    msg removing
    balena rm -f ${CONTAINER_NAME} || {
        echo "Błąd: Nie można usunąć kontenera ${CONTAINER_NAME}. Sprawdź logi: balena logs ${CONTAINER_NAME}"
        exit 1
    }
fi

# Uruchomienie nowego kontenera
msg starting
balena run -d \
  --privileged \
  -v ${HOST_VOLUME}:${CONTAINER_VOLUME} \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 31415:31415 -p 5432:5432 -p 3000:3000 \
  --cpus="${CPU_LIMIT}" \
  --memory="${RAM_LIMIT}g" \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  ${IMAGE} \
  /bin/bash -c "while true; do sleep 3600; done" || { msg error_container; exit 1; }

msg finished
echo "balena exec -it ${CONTAINER_NAME} /bin/bash"
```
