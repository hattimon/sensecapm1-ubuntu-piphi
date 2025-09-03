# PiPhi Network Installer for SenseCAP M1 with balenaOS (English)

This repository, based on [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main), provides two scripts to install PiPhi Network on SenseCAP M1 devices running balenaOS.

## Scripts
1. **install-piphi.sh**: Installs the Ubuntu container and basic setup.
2. **install-docker-piphi.sh**: Installs Docker and PiPhi in the Ubuntu container.

## Installation
1. Download and run `install-piphi.sh` on the host:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-piphi.sh
   chmod +x install-piphi.sh
   ./install-piphi.sh
   ```
2. Enter the Ubuntu container: `balena exec -it ubuntu-piphi /bin/bash`
3. Download and run `install-docker-piphi.sh` inside the container:
   ```
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-docker-piphi.sh
   chmod +x install-docker-piphi.sh
   ./install-docker-piphi.sh
   ```

## Reinstallation
To reinstall:
- Stop and remove the container: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Remove files: `rm -rf /mnt/data/piphi-network`
- Run the scripts again.

## Uninstallation
To uninstall:
- Stop and remove the container: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Remove files: `rm -rf /mnt/data/piphi-network`
- Remove temporary files: `rm /tmp/language`

# PiPhi Network Installer for SenseCAP M1 with balenaOS (Polski)

To repozytorium, oparte na [https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main](https://github.com/hattimon/sensecapm1-ubuntu-piphi/tree/main), zawiera dwa skrypty do instalacji PiPhi Network na urządzeniach SenseCAP M1 z balenaOS.

## Skrypty
1. **install-piphi.sh**: Instaluje kontener Ubuntu i podstawową konfigurację.
2. **install-docker-piphi.sh**: Instaluje Dockera i PiPhi w kontenerze Ubuntu.

## Instalacja
1. Pobierz i uruchom `install-piphi.sh` na hoście:
   ```
   cd /mnt/data
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-piphi.sh
   chmod +x install-piphi.sh
   ./install-piphi.sh
   ```
2. Wejdź do kontenera Ubuntu: `balena exec -it ubuntu-piphi /bin/bash`
3. Pobierz i uruchom `install-docker-piphi.sh` w kontenerze:
   ```
   wget https://raw.githubusercontent.com/hattimon/sensecapm1-ubuntu-piphi/main/install-docker-piphi.sh
   chmod +x install-docker-piphi.sh
   ./install-docker-piphi.sh
   ```

## Ponowna instalacja
Aby reinstallować:
- Zatrzymaj i usuń kontener: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Usuń pliki: `rm -rf /mnt/data/piphi-network`
- Uruchom skrypty ponownie.

## Odinstalowanie
Aby odinstalować:
- Zatrzymaj i usuń kontener: `balena stop ubuntu-piphi && balena rm ubuntu-piphi`
- Usuń pliki: `rm -rf /mnt/data/piphi-network`
- Usuń pliki tymczasowe: `rm /tmp/language`
