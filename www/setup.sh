#!/usr/bin/env bash
DOMAIN="beta.femiwiki.com"
WIKI_ID="femiwiki"
WIKI_NAME_EN="femiwiki"
WIKI_NAME_KR="페미위키"
WIKI_ADMIN_ID="Admin"
WIKI_ADMIN_PW="Admin"
WIKI_ADMIN_EMAIL="admin@femiwiki.com"

SCRIPTDIR=`dirname ${BASH_SOURCE}`

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
    memcached \
    php7.0 \
    php7.0-curl \
    php7.0-intl \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-xml \
    php-apcu \
    software-properties-common \
    unzip

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
sudo mkdir -p /opt/${WIKI_ID}_download
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
        --dbtype mysql --dbname ${WIKI_ID} \
        --dbserver localhost \
        --dbuser root \
        --dbpass root \
        --installdbuser root \
        --installdbpass root \
        --server https://${DOMAIN} \
        --lang ko --pass "${WIKI_ADMIN_PW}" "${WIKI_NAME_KR}" "${WIKI_ADMIN_ID}"
    sudo chown -R www-data:www-data /var/www/${DOMAIN}

    sudo mkdir -p /opt/${WIKI_ID}/cache
    sudo chown -R www-data:www-data /opt/${WIKI_ID}/cache
fi

# Copy files
sudo --user=www-data cp ${SCRIPTDIR}/wwwroot/* /var/www/${DOMAIN}/

# Configure apache2
sudo ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/
sudo ln -sf /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/
sudo ln -sf /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/

sudo rm -f /etc/apache2/sites-enabled/000-default.conf
sudo cp ${SCRIPTDIR}/apache.http.conf /etc/apache2/sites-available/${DOMAIN}.conf
sudo sed -i s/__DOMAIN__/${DOMAIN}/ /etc/apache2/sites-available/${DOMAIN}.conf
sudo ln -sf /etc/apache2/sites-available/${DOMAIN}.conf /etc/apache2/sites-enabled/

sudo apachectl restart

