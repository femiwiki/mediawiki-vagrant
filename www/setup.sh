#!/usr/bin/env bash
DOMAIN="beta.femiwiki.com"
WIKI_ID="femiwiki"
WIKI_NAME_EN="femiwiki"
WIKI_NAME_KR="페미위키"
WIKI_ADMIN_ID="Admin"
WIKI_ADMIN_PW="Admin"
WIKI_ADMIN_EMAIL="admin@femiwiki.com"

if [ ! -f /opt/${WIKI_ID}-provisioned ]; then
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
        memcached \
        php7.0 \
        php7.0-curl \
        php7.0-intl \
        php7.0-mbstring \
        php7.0-mysql \
        php7.0-xml \
        php-apcu \
        sendmail \
        software-properties-common \
        unzip

    # Install mariadb
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
    sudo apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        mariadb-server

    sudo mkdir -p /opt/${WIKI_ID}_download

    # Install mediawiki
    if [ ! -f /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz ]; then
        # Download and copy mediawiki source
        sudo wget -nv \
            https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.0.tar.gz \
            -O /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz

        sudo mkdir -p /var/www/${DOMAIN}
        sudo tar -xzf /opt/${WIKI_ID}_download/mediawiki-1.28.0.tar.gz --strip-components 1 -C /var/www/${DOMAIN}
        sudo chown -R www-data:www-data /var/www/${DOMAIN}

        # Run installation script
        sudo php /var/www/${DOMAIN}/maintenance/install.php \
            --scriptpath "/w" \
            --dbtype mysql --dbname ${WIKI_ID} \
            --dbserver localhost \
            --dbuser root \
            --dbpass root \
            --installdbuser root \
            --installdbpass root \
            --server https://${DOMAIN} \
            --lang ko --pass "${WIKI_ADMIN_PW}" \
            "${WIKI_NAME_KR}" "${WIKI_ADMIN_ID}"
    fi

    # Create SSL certificate
    if [ ! -f /usr/local/sbin/certbot-auto ]; then
        wget -nv https://dl.eff.org/certbot-auto -O /usr/local/sbin/certbot-auto
        sudo chmod a+x /usr/local/sbin/certbot-auto
        certbot-auto --noninteractive --apache -d ${DOMAIN} -m ${WIKI_ADMIN_EMAIL} --agree-tos
        sudo ln -sf /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/
        sudo ln -sf /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
        sudo crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/local/sbin/certbot-auto renew >> /var/log/le-renew.log" | sudo crontab -
    fi

    sudo rm -f /etc/apache2/sites-enabled/000-default.conf
fi
