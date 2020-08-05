#!/bin/bash
## Define some functions
function generatePassword() {
    openssl rand -hex 16
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "$@"" [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#Setup environments
environment() {
    if [ ! -f .env ]; then
        cp env.example .env
    fi
    if [ ! -f docker-compose.yml ]; then
        cp docker-compose.yml.example docker-compose.yml
    fi    

    source .env

    if [ "$SUPERUSER_PASSWORD" == "" ]; then
        SUPERUSER_PASSWORD=$(generatePassword)
    fi

    read -e -p "Servername: " -i "$SERVERNAME" SERVERNAME
    read -e -p "Admin Password: " -i "$SUPERUSER_PASSWORD" SUPERUSER_PASSWORD
    read -e -p "Allowed users: " -i "$USERS" USERS
    read -e -p "TCPPORT: " -i "$TCPPORT" TCPPORT
    read -e -p "UDPPORT: " -i "$TCPPORT" UDPPORT

    sed -i \
        -e "s#SUPERUSER_PASSWORD=.*#SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD}#g" \
        -e "s#DOMAIN=.*#DOMAIN=${DOMAIN}#g" \
        -e "s#SERVERNAME=.*#SERVERNAME=${SERVERNAME}#g" \
        -e "s#USERS=.*#USERS=${USERS}#g" \
        -e "s#TCPPORT=.*#TCPPORT=${TCPPORT}#g" \
        -e "s#UDPPORT=.*#UDPPORT=${UDPPORT}#g" \
        "$(dirname "$0")/.env"
}

#(Re)generate letsencrypt certificates
certificates() {
    if [ ! -f .env ]; then
        echo -e "No .env file found."
    else
        source .env
        DIR="${PWD}"

        sudo rm -rf letsencrypt
        mkdir -p letsencrypt

        cd "$DIR"
        sudo service nginx stop
        docker-compose down
        sleep 1
        cd letsencrypt
        docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 certbot/certbot certonly --standalone -d "${DOMAIN}"
        sudo service nginx start

        cd "$DIR"
        mkdir -p data
        sudo cp ./letsencrypt/etc/live/"$DOMAIN"/fullchain.pem ./data/cert.pem
        sudo cp ./letsencrypt/etc/live/"$DOMAIN"/privkey.pem ./data/key.pem
    fi
}

#Renew certificates
renew() {
    source .env
    DIR="${PWD}"

    cd "$DIR"
    sudo service nginx stop
    docker-compose down
    sleep 1
    cd letsencrypt
    docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 -p 443:443 certbot/certbot renew
    sudo service nginx start

    cd "$DIR"
    mkdir -p data
    sudo cp ./letsencrypt/etc/live/"$DOMAIN"/fullchain.pem ./data/cert.pem
    sudo cp ./letsencrypt/etc/live/"$DOMAIN"/privkey.pem ./data/key.pem

    docker-compose up -d
}

#Enable cronjob to renew certificates
enablecron() {
CRONTAB="SHELL=/bin/sh\nPATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n
15 3 * * * (cd ${PWD} ; ./install.sh -r)&
"
echo -e "$CRONTAB" > /etc/cron.d/mumblecerts
}

#Disable cronjob to renew certificates
disablecron() {
rm -f /etc/cron.d/mumblecerts
}

# ###### Parsing arguments

#Usage print
usage() {
    echo "Usage: $0 -[s|c|r|e|d]" >&2
    echo "
   -s,    Download setup.sh and environments
   -c,    (Re)generate letsencrypt certificates
   -r,    Renew certificates
   -e,    Enable cronjob to renew certificates
   -d,    Disable cronjob to renew certificates
   -h,    Print this help text

If the script will be called without parameters, it will start all steps one after another.
   "
    exit 1
}

while getopts ':scredh' opt
#putting : in the beginnnig suppresses the errors for invalid options
do
case "$opt" in
   's')environment;
       ;;
   'c')certificates;
       ;;
   'r')renew;
       ;; 
   'e')enablecron;
       ;;
   'd')disablecron;
       ;;
   'h')usage;
       ;;
    *) usage;
       ;;
esac
done
if [ $OPTIND -eq 1 ]; then
    if $(confirm "Setup environments?") ; then
        environment
    fi
    if $(confirm "(Re)generate letsencrypt certificates?") ; then
        certificates
    fi
    if $(confirm "Enable cronjob to renew certificates?") ; then
        enablecron
    fi
fi



