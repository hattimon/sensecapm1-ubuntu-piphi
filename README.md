# PiPhi Network Installer for SenseCAP M1 with balenaOS (English)

This repository provides two scripts to install PiPhi Network on SenseCAP M1 devices running balenaOS.

## Scripts
1. **install-piphi.sh**: Installs the Ubuntu container and basic setup.
2. **install-docker-piphi.sh**: Installs Docker and PiPhi in the Ubuntu container.

## Installation
1. Run `install-piphi.sh` on the host.
2. Enter the Ubuntu container: `balena exec -it ubuntu-piphi /bin/bash`
3. Run `install-docker-piphi.sh` inside the container.

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

To repozytorium zawiera dwa skrypty do instalacji PiPhi Network na urządzeniach SenseCAP M1 z balenaOS.

## Skrypty
1. **install-piphi.sh**: Instaluje kontener Ubuntu i podstawową konfigurację.
2. **install-docker-piphi.sh**: Instaluje Dockera i PiPhi w kontenerze Ubuntu.

## Instalacja
1. Uruchom `install-piphi.sh` na hoście.
2. Wejdź do kontenera Ubuntu: `balena exec -it ubuntu-piphi /bin/bash`
3. Uruchom `install-docker-piphi.sh` w kontenerze.

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
