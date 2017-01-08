#!/usr/bin/env bash
[ "${DOMAIN}" ] || DOMAIN="192.168.50.10"
[ "${PROTOCOL}" ] || PROTOCOL="http"
[ "${WIKI_ID}" ] || WIKI_ID="testwiki"
[ "${WIKI_NAME_EN}" ] || WIKI_NAME_EN="testwiki"
[ "${WIKI_NAME_KR}" ] || WIKI_NAME_KR="테스트위키"
[ "${WIKI_ADMIN_ID}" ] || WIKI_ADMIN_ID="Admin"
[ "${WIKI_ADMIN_PW}" ] || WIKI_ADMIN_PW="AdminAdmin"
[ "${WIKI_ADMIN_EMAIL}" ] || WIKI_ADMIN_EMAIL="suyooktang+testwiki@gmail.com"
[ "${PARSOID_DOMAIN}" ] || PARSOID_DOMAIN="192.168.50.11"

SCRIPTDIR=`dirname ${BASH_SOURCE}`
sudo mkdir -p /opt/${WIKI_ID}_download

# Set timezone
sudo timedatectl set-timezone Asia/Seoul

# Install prerequisites
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    apache2 \
    build-essential \
    git \
    imagemagick \
    libapache2-mod-php7.0 \
    php7.0 \
    php7.0-curl \
    php7.0-intl \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php-apcu \
    software-properties-common \
    unzip

# Configure php
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" /etc/php/7.0/apache2/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 10M/g" /etc/php/7.0/apache2/php.ini

# Install nodejs
if [ ! -f /usr/bin/nodejs ]; then
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install mariadb
if [ ! -f /usr/bin/mysql ]; then
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
    sudo apt-get install \
        -y \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        mariadb-server

    sudo mysqladmin -u root password "root"
    sudo mysql -u root -p"root" -e \
        "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root'"
    sudo mysql -u root -p"root" -e \
        "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
    sudo mysql -u root -p"root" -e \
        "DELETE FROM mysql.user WHERE User=''"
    sudo mysql -u root -p"root" -e \
        "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
    sudo mysql -u root -p"root" -e \
        "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
    sudo mysql -u root -p"root" -e \
        "USE mysql; UPDATE user SET plugin='' WHERE User='root';"
    sudo mysql -u root -p"root" -e \
        "FLUSH PRIVILEGES"
fi

# Install mediawiki
if [ ! -f /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz ]; then
    # Download and copy mediawiki source
    sudo wget -nv \
        https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz \
        -O /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz

    sudo mkdir -p /var/www/${DOMAIN}
    sudo tar -xzf /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz --strip-components 1 -C /var/www/${DOMAIN}

    # Run installation script
    sudo php /var/www/${DOMAIN}/maintenance/install.php \
        --scriptpath "/w" \
        --dbserver localhost \
        --dbtype mysql --dbname ${WIKI_ID} \
        --dbuser root --dbpass root \
        --installdbuser root --installdbpass root \
        --server ${PROTOCOL}://${DOMAIN} \
        --lang ko \
        --pass "${WIKI_ADMIN_PW}" \
        "${WIKI_NAME_KR}" "${WIKI_ADMIN_ID}"
    sudo mv /var/www/${DOMAIN}/LocalSettings.php /var/www/${DOMAIN}/LocalSettings.base.php
    sudo chown -R www-data:www-data /var/www/${DOMAIN}

    sudo mkdir -p /opt/${WIKI_ID}/cache
    sudo chown -R www-data:www-data /opt/${WIKI_ID}/cache
fi
sudo --user=www-data cp ${SCRIPTDIR}/LocalSettings.php /var/www/${DOMAIN}/
sudo sed -i s/__DOMAIN__/${DOMAIN}/g /var/www/${DOMAIN}/LocalSettings.php
sudo sed -i s/__PARSOID_DOMAIN__/${PARSOID_DOMAIN}/g /var/www/${DOMAIN}/LocalSettings.php
sudo sed -i s/__WIKI_ID__/${WIKI_ID}/g /var/www/${DOMAIN}/LocalSettings.php
sudo sed -i s/__WIKI_ADMIN_EMAIL__/${WIKI_ADMIN_EMAIL}/g /var/www/${DOMAIN}/LocalSettings.php

# Install mediawiki extensions
## VisualEditor
if [ ! -f /opt/${WIKI_ID}_download/VisualEditor.tar.gz ]; then
    sudo wget -nv \
        https://extdist.wmflabs.org/dist/extensions/VisualEditor-REL1_28-93528b7.tar.gz \
        -O /opt/${WIKI_ID}_download/VisualEditor.tar.gz
    sudo tar -xzf /opt/${WIKI_ID}_download/VisualEditor.tar.gz -C /var/www/${DOMAIN}/extensions
fi

# Copy static files
sudo --user=www-data cp ${SCRIPTDIR}/wwwroot/* /var/www/${DOMAIN}/

# Install restbase
if [ ! -d /opt/${WIKI_ID}/restbase ]; then
    sudo git clone https://github.com/wikimedia/restbase.git /opt/${WIKI_ID}/restbase
    cd /opt/${WIKI_ID}/restbase && sudo npm install && cd -
fi
sudo cp ${SCRIPTDIR}/config.restbase.yaml /opt/${WIKI_ID}/restbase/config.yaml
sudo sed -i s/__DOMAIN__/${DOMAIN}/g /opt/${WIKI_ID}/restbase/config.yaml
sudo sed -i s/__PROTOCOL__/${PROTOCOL}/g /opt/${WIKI_ID}/restbase/config.yaml
sudo sed -i s/__PARSOID_DOMAIN__/${PARSOID_DOMAIN}/g /opt/${WIKI_ID}/restbase/config.yaml
sudo cp ${SCRIPTDIR}/restbase.systemd.service /lib/systemd/system/restbase.service
sudo sed -i s/__DOMAIN__/${DOMAIN}/g /lib/systemd/system/restbase.service
sudo sed -i s/__WIKI_ID__/${WIKI_ID}/g /lib/systemd/system/restbase.service
sudo systemctl daemon-reload
sudo systemctl restart restbase
sudo systemctl enable restbase.service

# Configure apache2
sudo a2enmod rewrite
sudo a2enmod expires
sudo a2enmod socache_shmcb

sudo rm -f /etc/apache2/sites-enabled/000-default.conf
sudo cp ${SCRIPTDIR}/apache.http.conf /etc/apache2/sites-available/${DOMAIN}.conf
sudo sed -i s/__DOMAIN__/${DOMAIN}/g /etc/apache2/sites-available/${DOMAIN}.conf
sudo ln -sf /etc/apache2/sites-available/${DOMAIN}.conf /etc/apache2/sites-enabled/

sudo service apache2 restart

