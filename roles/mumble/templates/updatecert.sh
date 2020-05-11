#!/bin/bash
DIR="${PWD}"

. "./.env"

cd "$DIR"

sudo service nginx stop
docker-compose down
sleep 1
cd letsencrypt
docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 certbot/certbot renew
sudo service nginx start

cd "$DIR"

sudo cp ./letsencrypt/etc/live/"$DOMAIN"/fullchain.pem ./data/cert.pem
sudo cp ./letsencrypt/etc/live/"$DOMAIN"/privkey.pem ./data/key.pem

docker-compose up -d


