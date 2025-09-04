#!/bin/bash

# Skrypt: ubuntu-piphi-resources.sh
# Cel: zmiana CPU i RAM kontenera ubuntu-piphi w BalenaOS, zachowanie danych i automatyczny restart

CONFIG_FILE="$HOME/.ubuntu_piphi_config"
CONTAINER_NAME="ubuntu-piphi"
HOST_VOLUME="/mnt/data/piphi-network"
CONTAINER_VOLUME="/piphi-network"
IMAGE="ubuntu:20.04"

# Funkcja do wczytania ostatnich ustawień
load_last_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        CPU_LIMIT="1.0"
        RAM_LIMIT="2g"
    fi
}

# Funkcja do zapisania ustawień
save_config() {
    echo "CPU_LIMIT=\"$CPU_LIMIT\"" > "$CONFIG_FILE"
    echo "RAM_LIMIT=\"$RAM_LIMIT\"" >> "$CONFIG_FILE"
}

# Wczytanie ostatnich ustawień
load_last_config

# Pobranie nowych parametrów od użytkownika (domyślnie ostatnio używane)
read -p "Podaj liczbę rdzeni CPU dla kontenera [$CPU_LIMIT]: " CPU_INPUT
CPU_LIMIT=${CPU_INPUT:-$CPU_LIMIT}

read -p "Podaj ilość RAM dla kontenera [$RAM_LIMIT]: " RAM_INPUT
RAM_LIMIT=${RAM_INPUT:-$RAM_LIMIT}

# Zapisanie nowych ustawień
save_config

# Sprawdzenie czy kontener istnieje i jego usunięcie
if balena ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Kontener ${CONTAINER_NAME} już istnieje. Usuwam..."
    balena rm -f ${CONTAINER_NAME}
fi

# Uruchomienie nowego kontenera
echo "Uruchamianie kontenera ${CONTAINER_NAME} z CPU=${CPU_LIMIT} RAM=${RAM_LIMIT}..."
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

echo "Kontener uruchomiony. Możesz wejść do niego poleceniem:"
echo "balena exec -it ${CONTAINER_NAME} /bin/bash"
