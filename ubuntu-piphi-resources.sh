# Zatrzymaj kontener
balena stop ubuntu-piphi

# Usuń kontener
balena rm ubuntu-piphi

# Uruchom ponownie z poprawnymi limitami
balena run -d \
  --privileged \
  -v /mnt/data/piphi-network:/piphi-network \
  -p 31415:31415 -p 5432:5432 -p 3000:3000 \
  --memory="2g" \
  --cpu-quota=100000 --cpu-period=100000 \
  --name ubuntu-piphi \
  --restart unless-stopped \
  ubuntu:20.04 \
  /bin/bash -c "while true; do sleep 3600; done"
