PiPhi Network Installer for SenseCAP M1 with balenaOS (English)
This repository provides two scripts to install PiPhi Network on SenseCAP M1 devices running balenaOS.
Scripts

install-piphi.sh: Installs the Ubuntu container and basic setup.
install-docker-piphi.sh: Installs Docker and PiPhi in the Ubuntu container.

Installation

Run install-piphi.sh on the host.
Enter the Ubuntu container: balena exec -it ubuntu-piphi /bin/bash
Run install-docker-piphi.sh inside the container.

Reinstallation
To reinstall:

Stop and remove the container: balena stop ubuntu-piphi && balena rm ubuntu-piphi
Remove files: rm -rf /mnt/data/piphi-network
Run the scripts again.

Uninstallation
To uninstall:

Stop and remove the container: balena stop ubuntu-piphi && balena rm ubuntu-piphi
Remove files: rm -rf /mnt/data/piphi-network
Remove temporary files: rm /tmp/language

PiPhi Network Installer for SenseCAP M1 with balenaOS (Polski)
To repozytorium zawiera dwa skrypty do instalacji PiPhi Network na urządzeniach SenseCAP M1 z balenaOS.
Skrypty

install-piphi.sh: Instaluje kontener Ubuntu i podstawową konfigurację.
install-docker-piphi.sh: Instaluje Dockera i PiPhi w kontenerze Ubuntu.

Instalacja

Uruchom install-piphi.sh na hoście.
Wejdź do kontenera Ubuntu: balena exec -it ubuntu-piphi /bin/bash
Uruchom install-docker-piphi.sh w kontenerze.

Ponowna instalacja
Aby reinstallować:

Zatrzymaj i usuń kontener: balena stop ubuntu-piphi && balena rm ubuntu-piphi
Usuń pliki: rm -rf /mnt/data/piphi-network
Uruchom skrypty ponownie.

Odinstalowanie
Aby odinstalować:

Zatrzymaj i usuń kontener: balena stop ubuntu-piphi && balena rm ubuntu-piphi
Usuń pliki: rm -rf /mnt/data/piphi-network
Usuń pliki tymczasowe: rm /tmp/language
