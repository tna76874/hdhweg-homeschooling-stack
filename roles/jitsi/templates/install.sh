#!/bin/bash

function generatePassword() {
    openssl rand -hex 16
}

JICOFO_COMPONENT_SECRET=$(generatePassword)
JICOFO_AUTH_PASSWORD=$(generatePassword)
JVB_AUTH_PASSWORD=$(generatePassword)
JIGASI_XMPP_PASSWORD=$(generatePassword)
JIBRI_RECORDER_PASSWORD=$(generatePassword)
JIBRI_XMPP_PASSWORD=$(generatePassword)

sed -i.bak \
    -e "s#JICOFO_COMPONENT_SECRET=.*#JICOFO_COMPONENT_SECRET=${JICOFO_COMPONENT_SECRET}#g" \
    -e "s#JICOFO_AUTH_PASSWORD=.*#JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}#g" \
    -e "s#JVB_AUTH_PASSWORD=.*#JVB_AUTH_PASSWORD=${JVB_AUTH_PASSWORD}#g" \
    -e "s#JIGASI_XMPP_PASSWORD=.*#JIGASI_XMPP_PASSWORD=${JIGASI_XMPP_PASSWORD}#g" \
    -e "s#JIBRI_RECORDER_PASSWORD=.*#JIBRI_RECORDER_PASSWORD=${JIBRI_RECORDER_PASSWORD}#g" \
    -e "s#JIBRI_XMPP_PASSWORD=.*#JIBRI_XMPP_PASSWORD=${JIBRI_XMPP_PASSWORD}#g" \
    "$(dirname "$0")/.env"

mkdir -p /srv/jitsi/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

cp interface_config.js /srv/jitsi/.jitsi-meet-cfg/web/
cp config.js /srv/jitsi/.jitsi-meet-cfg/web/
cp logging.properties /srv/jitsi/.jitsi-meet-cfg/jvb/

docker-compose up -d
