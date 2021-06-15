# Manual Certificate Refresh
Steps to follow to updated the unifi certificate, put it in correct docker compose folder, (re)pull the newest docker images and restart the services

```bash
# run certbot to get the new certificate
sudo certbot certonly --manual --update --preferred-challenges dns

# put yourself in the right directory
cd docker/unifi/cert/

# copy the new certificate files into the correct (docker-compose image) folder
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/cert.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/chain.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/fullchain.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/privkey.pem .

#put yourself in the right directory
cd ../..

# pull the latest docker images, stop the service and start it as a daemon
docker-compose pull
docker-compose down
docker-compose up -d --build
```