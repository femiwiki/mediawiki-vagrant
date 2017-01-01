#!/usr/bin/env bash
DOMAIN="beta.femiwiki.com"
WIKI_ADMIN_EMAIL="admin@femiwiki.com"

# Enable apache modules
sudo ln -sf /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled
sudo apachectl restart

# Create SSL certificate
if [ ! -f /usr/local/sbin/certbot-auto ]; then
    sudo wget -nv https://dl.eff.org/certbot-auto -O /usr/local/sbin/certbot-auto
    sudo chmod a+x /usr/local/sbin/certbot-auto
    sudo certbot-auto --noninteractive --apache -d ${DOMAIN} -m ${WIKI_ADMIN_EMAIL} --agree-tos
    sudo ln -sf /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/
    sudo ln -sf /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
    sudo crontab -l 2>/dev/null; echo "30 2 * * 1 /usr/local/sbin/certbot-auto renew >> /var/log/le-renew.log" | sudo crontab -
fi

