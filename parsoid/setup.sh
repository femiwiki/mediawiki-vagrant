#!/usr/bin/env bash
[ "${DOMAIN}" ] || DOMAIN="192.168.50.10"
[ "${PROTOCOL}" ] || PROTOCOL="http"

SCRIPTDIR=`dirname ${BASH_SOURCE}`

sudo apt-key advanced --keyserver pgp.mit.edu --recv-keys 90E9F83F22250DD7
sudo apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main"
sudo apt-get update && sudo apt-get install -y parsoid
sudo cp ${SCRIPTDIR}/config.yaml /etc/mediawiki/parsoid/config.yaml
sudo sed -i s/__PROTOCOL__/${PROTOCOL}/ /etc/mediawiki/parsoid/config.yaml
sudo sed -i s/__DOMAIN__/${DOMAIN}/ /etc/mediawiki/parsoid/config.yaml

sudo service parsoid restart
