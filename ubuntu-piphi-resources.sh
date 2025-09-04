#!/bin/bash

# Skrypt: ubuntu-piphi-resources.sh
# Cel: zmiana CPU i RAM kontenera ubuntu-piphi w BalenaOS, zachowanie danych i automatyczny restart
# Dodano wybór języka (angielski / polski)

CONFIG_FILE="$HOME/.ubuntu_piphi_config"
CONTAINER_NAME="ubuntu-piphi"
HOST_VOLUME="/mnt/data/piphi-network"
CONTAINER_VOLUME="/piphi-network"
IMAGE="ubuntu:20.04"

# -----------------------
# Funkcje językowe
# -----------------------
choose_language() {
    echo "Select language / Wybierz język:"
    echo "1) English (default)"
    echo "2) Polski"
    read -p "Choice / Wybór [1]: " LANG_CHOICE
    case "$LANG_CHOICE" in
        2) LANG="PL" ;;
        *) LANG="EN" ;;
    esac
}

# Funkcja do wyświetlania komunikatów w wybranym języku
msg() {
    if [ "$LANG" = "PL" ]; then
        case $1 in
            cpu_prompt) echo -n "Podaj liczbę rdzeni CPU dla kontenera [$CPU_LIMIT]: " ;;
            ram_prompt) echo -n "Podaj ilość RAM dla kontenera [$RAM_LIMIT]: " ;;
            removing) echo "Kontener ${CONTAINER_NAME} już istnieje. Usuwam..." ;;
            starting) echo "Uruchamianie kontenera ${CONTAINER_NAME} z CPU=${CPU_LIMIT} RAM=${RAM_LIMIT}..." ;;
            finished) echo "Kontener uruchomiony. Możesz wejść do niego poleceniem:" ;;
        esac
    else
        case $1 in
            cpu_prompt) echo -n "Enter number of CPU cores for the container [$CPU_LIMIT]: " ;;
            ram_prompt) echo -n "Enter amount of RAM for the container [$RAM_LIMIT]: " ;;
            removing) echo "Container ${CONTAINER_NAME} already exists. Removing..." ;;
            starting) echo "Starting container ${CONTAINER_NAME} with CPU=${CPU_LIMIT} RAM=${RAM_LIMIT}..." ;;
            finished) echo "Container started. You can access it with:" ;;
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
        CPU_LIMIT="1.0"
        RAM_LIMIT="2g"
    fi
}

save_config() {
    echo "CPU_LIMIT=\"$CPU_LIMIT\"" > "$CONFIG_FILE"
    echo "RAM_LIMIT=\"$RAM_LIMIT\"" >> "$CONFIG_FILE"
}

# -----------------------
# Główny skrypt
# -----------------------
choose_language
load_last_config

# Pobranie parametrów od użytkownika
msg cpu_prompt
read CPU_INPUT
CPU_LIMIT=${CPU_INPUT:-$CPU_LIMIT}

msg ram_prompt
read RAM_INPUT
RAM_LIMIT=${RAM_INPUT:-$RAM_LIMIT}

save_config

# Sprawdzenie czy kontener istnieje
if balena ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    msg removing
    balena rm -f ${CONTAINER_NAME}
fi

# Uruchomienie nowego kontenera
msg starting
balena run -d \
  --privileged \
  -v ${HOST_VOLUME}:${CONTAINER_VOLUME} \
  -p 31415:31415 -p 5432:5432 -p 3000:3000 \
  --cpus="${CPU_LIMIT}" \
  --memory="${RAM_LIMIT}" \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  ${IMAGE} \
  /bin/bash -c "while true; do sleep 3600; done"

msg finished
echo "balena exec -it ${CONTAINER_NAME} /bin/bash"
