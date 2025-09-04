# PiPhi Network Installer for SenseCAP M1 with balenaOS (English)

This repository, based on [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main), provides scripts to install PiPhi Network on SenseCAP M1 devices running balenaOS, with support for USB GPS dongles and resource management.

## Prerequisites
- Connect a USB GPS dongle (e.g., U-Blox 7) to the SenseCAP M1.

## Scripts
1. **install-piphi.sh**: Installs the Ubuntu container and basic setup.
2. **install-docker-piphi.sh**: Installs Docker and PiPhi in the Ubuntu container, including GPS support.
3. **ubuntu-piphi-resources.sh**: Configures CPU and RAM limits for the `ubuntu-piphi` container with language selection (English/Polish).

## Installation
1. Download and run `install-piphi.sh` on the host:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-piphi.sh
   chmod +x install-piphi.sh
   ./install-piphi.sh
   ```
2. Enter the Ubuntu container: `balena exec -it ubuntu-piphi /bin/bash`
3. Install `wget` inside the Ubuntu container: `apt-get update && apt-get install -y wget`
4. Download and run `install-docker-piphi.sh` inside the container:
   ```
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-docker-piphi.sh
   chmod +x install-docker-piphi.sh
   ./install-docker-piphi.sh
   ```

## Resource Configuration
To configure CPU and RAM limits for the `ubuntu-piphi` container:
1. Download and run `ubuntu-piphi-resources.sh` on the host:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/ubuntu-piphi-resources.sh
   chmod +x ubuntu-piphi-resources.sh
   ./ubuntu-piphi-resources.sh
   ```
2. Follow the prompts to select the language (English or Polish) and specify CPU cores and RAM limits.
3. The script will restart the container with the new resource settings and preserve existing data.

## Reinstallation
To reinstall:
- Stop and remove the container: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Remove files: `rm -rf /mnt/data/piphi-network`
- Run the scripts again (`install-piphi.sh`, `install-docker-piphi.sh`, and optionally `ubuntu-piphi-resources.sh`).

## Uninstallation
To uninstall:
- Stop and remove the container: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Remove files: `rm -rf /mnt/data/piphi-network`
- Remove temporary files: `rm /tmp/language`

## GPS Configuration
- After installation, verify GPS functionality by running `cgps -s` inside the container.
- Note: Place the device outdoors for a GPS fix (1–5 minutes) if no signal is detected.
- Ensure the GPS dongle is recognized as `/dev/ttyACM0` (check with `ls /dev/ttyACM*`).

## Testing and Verification
- **On balenaOS Host**: After running `install-piphi.sh`, verify the GPS dongle is detected by running `ls /dev/ttyACM*` and check logs with `balena logs ubuntu-piphi` to ensure the container starts correctly.
- **In Ubuntu Container**: After running `install-docker-piphi.sh`, verify Docker services with `docker compose ps`, check GPS with `cgps -s`, and ensure the PiPhi panel is accessible at `http://<device IP>:31415`.

# PiPhi Network Installer for SenseCAP M1 with balenaOS (Polski)

To repozytorium, oparte na [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main), zawiera skrypty do instalacji PiPhi Network na urządzeniach SenseCAP M1 z balenaOS, z obsługą dongli USB GPS i zarządzaniem zasobami.

## Wymagania wstępne
- Podłącz dongle USB GPS (np. U-Blox 7) do SenseCAP M1.

## Skrypty
1. **install-piphi.sh**: Instaluje kontener Ubuntu i podstawową konfigurację.
2. **install-docker-piphi.sh**: Instaluje Dockera i PiPhi w kontenerze Ubuntu, w tym obsługę GPS.
3. **ubuntu-piphi-resources.sh**: Konfiguruje limity CPU i RAM dla kontenera `ubuntu-piphi` z wyborem języka (angielski/polski).

## Instalacja
1. Pobierz i uruchom `install-piphi.sh` na hoście:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-piphi.sh
   chmod +x install-piphi.sh
   ./install-piphi.sh
   ```
2. Wejdź do kontenera Ubuntu: `balena exec -it ubuntu-piphi /bin/bash`
3. Zainstaluj `wget` w kontenerze Ubuntu: `apt-get update && apt-get install -y wget`
4. Pobierz i uruchom `install-docker-piphi.sh` w kontenerze:
   ```
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-docker-piphi.sh
   chmod +x install-docker-piphi.sh
   ./install-docker-piphi.sh
   ```

## Konfiguracja zasobów
Aby skonfigurować limity CPU i RAM dla kontenera `ubuntu-piphi`:
1. Pobierz i uruchom `ubuntu-piphi-resources.sh` na hoście:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/ubuntu-piphi-resources.sh
   chmod +x ubuntu-piphi-resources.sh
   ./ubuntu-piphi-resources.sh
   ```
2. Postępuj zgodnie z instrukcjami, aby wybrać język (angielski lub polski) i określić limity rdzeni CPU oraz RAM.
3. Skrypt zrestartuje kontener z nowymi ustawieniami zasobów, zachowując istniejące dane.

## Ponowna instalacja
Aby reinstallować:
- Zatrzymaj i usuń kontener: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Usuń pliki: `rm -rf /mnt/data/piphi-network`
- Uruchom skrypty ponownie (`install-piphi.sh`, `install-docker-piphi.sh` oraz opcjonalnie `ubuntu-piphi-resources.sh`).

## Odinstalowanie
Aby odinstalować:
- Zatrzymaj i usuń kontener: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Usuń pliki: `rm -rf /mnt/data/piphi-network`
- Usuń pliki tymczasowe: `rm /tmp/language`

## Konfiguracja GPS
- Po instalacji zweryfikuj funkcjonalność GPS, uruchamiając `cgps -s` w kontenerze.
- Uwaga: Umieść urządzenie na zewnątrz dla fix GPS (1–5 minut), jeśli sygnał nie jest wykryty.
- Upewnij się, że dongle GPS jest rozpoznawany jako `/dev/ttyACM0` (sprawdź za pomocą `ls /dev/ttyACM*`).

## Testowanie i Weryfikacja
- **Na hoście balenaOS**: Po uruchomieniu `install-piphi.sh` sprawdź, czy dongle GPS jest wykryty, wykonując `ls /dev/ttyACM*`, oraz zweryfikuj logi kontenera komendą `balena logs ubuntu-piphi`, aby upewnić się, że kontener startuje poprawnie.
- **W kontenerze Ubuntu**: Po uruchomieniu `install-docker-piphi.sh` zweryfikuj usługi Dockera za pomocą `docker compose ps`, sprawdź GPS komendą `cgps -s` oraz upewnij się, że panel PiPhi jest dostępny pod adresem `http://<IP urządzenia>:31415`.
