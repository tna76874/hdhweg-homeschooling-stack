#!/bin/bash

function generatePassword() {
    openssl rand -hex 16
}

if [ ! -f docker-compose.yml ]; then
    cp docker-compose.yml.example docker-compose.yml
fi  
if [ ! -f .env ]; then
    docker-compose down

    sudo rm -rf data

    cp env.example .env

    source .env

    JICOFO_COMPONENT_SECRET=$(generatePassword)
    JICOFO_AUTH_PASSWORD=$(generatePassword)
    JVB_AUTH_PASSWORD=$(generatePassword)
    JIGASI_XMPP_PASSWORD=$(generatePassword)
    JIBRI_RECORDER_PASSWORD=$(generatePassword)
    JIBRI_XMPP_PASSWORD=$(generatePassword)
    LETSENCRYPT_DOMAIN="jitsi.mydomain.xyz"  
    HTTP_PORT="8000"

    mkdir -p ./data/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

    sed -i \
        -e "s#JICOFO_COMPONENT_SECRET=.*#JICOFO_COMPONENT_SECRET=${JICOFO_COMPONENT_SECRET}#g" \
        -e "s#JICOFO_AUTH_PASSWORD=.*#JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}#g" \
        -e "s#JVB_AUTH_PASSWORD=.*#JVB_AUTH_PASSWORD=${JVB_AUTH_PASSWORD}#g" \
        -e "s#JIGASI_XMPP_PASSWORD=.*#JIGASI_XMPP_PASSWORD=${JIGASI_XMPP_PASSWORD}#g" \
        -e "s#JIBRI_RECORDER_PASSWORD=.*#JIBRI_RECORDER_PASSWORD=${JIBRI_RECORDER_PASSWORD}#g" \
        -e "s#JIBRI_XMPP_PASSWORD=.*#JIBRI_XMPP_PASSWORD=${JIBRI_XMPP_PASSWORD}#g" \
        -e "s#HTTP_PORT=.*#HTTP_PORT=${HTTP_PORT}#g" \
        -e "s#.*LETSENCRYPT_DOMAIN=.*#LETSENCRYPT_DOMAIN=${LETSENCRYPT_DOMAIN}#g" \
        "$(dirname "$0")/.env"

    cp interface_config.js /srv/jitsi/.jitsi-meet-cfg/web/
    cp config.js /srv/jitsi/.jitsi-meet-cfg/web/
    cp logging.properties /srv/jitsi/.jitsi-meet-cfg/jvb/

    docker-compose up -d
else
    echo -e "To reinstall, please delete .env file."
fi





