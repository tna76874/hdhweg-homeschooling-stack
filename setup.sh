#!/bin/bash

set -eu

#exit if not run by root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#getting some environment vars
source /etc/lsb-release

# setting the location of the ansible playbook repository
export GITREPO="https://github.com/tna76874/hdhweg-homeschooling-stack.git"
export REPODIR="/root/hdhweg-homeschooling-stack"
export EXE="/usr/local/bin/setup.sh"
export SCRIPT=$(readlink -f "$0")

# installing requirements
installing_requirements() {
    echo -e "... update system sources, install ansible and git and clone the playbook repository ... [this could take a few minutes now, depending on your internet connection]"
    sudo apt update > /dev/null 2>&1
    sudo apt install software-properties-common -y > /dev/null 2>&1
    sudo apt-add-repository universe > /dev/null 2>&1
    sudo apt-add-repository multiverse > /dev/null 2>&1
    if [ "$DISTRIB_CODENAME" = "bionic" ]
    then
        sudo apt-add-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
    fi
    sudo apt update > /dev/null 2>&1
    sudo apt install nano git ansible -y > /dev/null 2>&1
}

# pulling repo and updating content
pull_repo() {
    # pulling latest changes
    sudo git -C ${REPODIR} pull  > /dev/null 2>&1

    # install galaxy roles
    ansible-galaxy install -r ${REPODIR}/requirements.yml  > /dev/null 2>&1
}

# checking for required packages
git version > /dev/null 2>&1 && ansible-playbook -h > /dev/null 2>&1 || installing_requirements

# checking if repo dir is present
if [ ! -d "$REPODIR" ]; then
    echo "Cloning repo to: $REPODIR"
    sudo git clone ${GITREPO} ${REPODIR} > /dev/null 2>&1
    sudo cp ${REPODIR}/vars.yml.example ${REPODIR}/vars.yml
    sudo cp ${REPODIR}/inventory.example ${REPODIR}/inventory
    echo -e "Edit variables now with:\nnano ${REPODIR}/vars.yml"
else
    pull_repo
fi

# checking if script is deployed on system
if [ ! -f "$EXE" ]; then
    echo "Deploy as system script: $EXE"
    sudo cp ${SCRIPT} ${EXE}
    sudo chmod 775 ${EXE}
fi

# processing args
while [ $# -gt 0 ] ; do
  case $1 in
    -t | --tag | tag) sudo ansible-playbook ${REPODIR}/main.yml -t base,"$2" ;;
  esac
  shift
done