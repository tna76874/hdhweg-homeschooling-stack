#!/bin/bash
function generatePassword() {
    openssl rand -hex 16
}

SUPERUSER_PASSWORD=$(generatePassword)
read -p "Domain: " DOMAIN
read -p "Servername: " -i "Mumbleserver" SERVERNAME
read -p "Allowed users: " -i "500" USERS
read -e -p "TCPPORT: " -i "64738" TCPPORT
read -e -p "UDPPORT: " -i "$TCPPORT" UDPPORT

sed -i \
    -e "s#SUPERUSER_PASSWORD=.*#SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD}#g" \
    -e "s#DOMAIN=.*#DOMAIN=${DOMAIN}#g" \
    -e "s#SERVERNAME=.*#SERVERNAME=${SERVERNAME}#g" \
    -e "s#USERS=.*#USERS=${USERS}#g" \
    "$(dirname "$0")/.env"

. "./.env"

./getcert.sh

cp ufw_mumble ufw_mumble.bak

sed -i \
    -e "s#TCPPORT#${TCPPORT}#g" \
    -e "s#UDPPORT#${UDPPORT}#g" \
    "$(dirname "$0")/ufw_mumble.bak"

sudo cp ufw_mumble.bak /etc/ufw/applications.d/ufw_mumble
rm ufw_mumble.bak
sudo ufw reload
sudo ufw allow mumble

mkdir -p data
cp welcometext ./data/

docker-compose up -d
