#!/bin/bash
## Define some functions

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SSCRIPT")

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

    mkdir -p {data,data/data}
    cp welcometext ./data/data

    source .env

    if [ "$SUPERUSER_PASSWORD" == "" ]; then
        SUPERUSER_PASSWORD=$(generatePassword)
    fi

    sed -i \
        -e "s#SUPERUSER_PASSWORD=.*#SUPERUSER_PASSWORD=${SUPERUSER_PASSWORD}#g" \
        -e "s#DOMAIN=.*#DOMAIN=${WEBDOMAIN}#g" \
        -e "s#WEBDOMAIN=.*#WEBDOMAIN=${WEBDOMAIN}#g" \
        -e "s#MUMBLE_REGISTERNAME=.*#MUMBLE_REGISTERNAME=\"${MUMBLE_REGISTERNAME}\"#g" \
        -e "s#USERS=.*#MUMBLE_USERS=${MUMBLE_USERS}#g" \
        -e "s#TCPPORT=.*#TCPPORT=${TCPPORT}#g" \
        -e "s#UDPPORT=.*#UDPPORT=${TCPPORT}#g" \
        -e "s#WEBPORT=.*#WEBPORT=${WEBPORT}#g" \
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
        sudo docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 certbot/certbot certonly --standalone -d "${DOMAIN}"
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
    sudo docker run --rm -ti -v $PWD/log/:/var/log/letsencrypt/ -v $PWD/etc/:/etc/letsencrypt/ -p 80:80 -p 443:443 certbot/certbot renew
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

# Install prerequisites (docker, docker-compose)
# https://docs.docker.com/engine/install/ubuntu/
prerequisites() {
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -qy \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -qy \
        docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker $USER
    sudo systemctl restart docker
    newgrp docker
}

nginxit() {
cd "$DIR"
if $(confirm "--Install nginx and certbot?") ; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common nginx -qy
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe
    sudo DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install certbot python3-certbot-nginx -qy
fi
if [ ! -f .env ]; then
        echo -e "No .env file found." 
else
    cp nginx.example nginx
    source .env

    sed -i \
        -e "s/TCPPORT/${WEBPORT}/g" \
        -e "s/MYDOMAIN/${WEBDOMAIN}/g" \
        "$(dirname "$0")/nginx"

    sudo cp nginx /etc/nginx/sites-available/"${WEBDOMAIN}"
    rm nginx
    sudo ln -s /etc/nginx/sites-available/"${WEBDOMAIN}" /etc/nginx/sites-enabled/"${WEBDOMAIN}"
    if $(confirm "--Purge all keys in /etc/letsencrypt/[live|archive]/${WEBDOMAIN}*?") ; then
        rm -rf /etc/letsencrypt/live/${WEBDOMAIN}*
        rm -rf /etc/letsencrypt/archive/${WEBDOMAIN}*
    fi
    sudo certbot --nginx --expand -d "${WEBDOMAIN}"
fi
}

unlinkhtml() {
if [ ! -f .env ]; then
        echo -e "No .env file found." 
else
    source .env
    sudo unlink /etc/nginx/sites-enabled/"${WEBDOMAIN}"
fi
}

# ###### Parsing arguments

#Usage print
usage() {
    echo "Usage: $0 -[p|s|r|n|d]" >&2
    echo "
   -p,      Install prerequisites (docker, docker-compose)
   -s,      Setup environment
   -r,      Disable cronjob to renew certificates
   -n,      Generate nginx virtual and certificates
   -d,      Deactivate access to HTML client
   -h,      Print this help text

If the script will be called without parameters, it will run:
    $0 -p -s -n
   ">&2
    exit 1
}

while getopts ':psrnd' opt
#putting : in the beginnnig suppresses the errors for invalid options
do
case "$opt" in
   'p')prerequisites;
       ;;
   's')environment;
       ;;
   'r')disablecron;
       ;;
   'n')nginxit;
       ;;
   'd')unlinkhtml;
       ;;
    *) usage;
       ;;
esac
done
if [ $OPTIND -eq 1 ]; then
    if $(confirm "Install prerequisites (docker, docker-compose)?") ; then
        cd "$DIR"
        prerequisites
    fi
    if $(confirm "Setup environments?") ; then
        cd "$DIR"
        environment
    fi
    if $(confirm "Generate nginx virtual and certificates?") ; then
        cd "$DIR"
        nginxit
    fi
    if $(confirm "Startup docker-compose?") ; then
        cd "$DIR"
        docker-compose up -d
    fi
fi



