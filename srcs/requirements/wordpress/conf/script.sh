#!/bin/bash

# Définir le répertoire de travail
cd /var/www/html

# Télécharger WP-CLI avec --insecure si nécessaire
curl -o wp-cli.phar --insecure https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Rendre WP-CLI exécutable
chmod +x wp-cli.phar

# Télécharger WordPress avec WP-CLI
./wp-cli.phar core download --allow-root

sed -i "s/database_name_here/$WP_DB_NAME/g" wp-config-sample.php
sed -i "s/username_here/$WP_DB_USER/g" wp-config-sample.php
sed -i "s/password_here/$WP_DB_PASSWORD/g" wp-config-sample.php
sed -i "s/localhost/$DB_HOSTNAME/g" wp-config-sample.php
cp wp-config-sample.php wp-config.php

# Installer WordPress
./wp-cli.phar core install --url=$DOMAIN_NAME --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --allow-root

./wp-cli.phar user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root

# Démarrer PHP-FPM
echo "STARTING PHP-FPM"
php-fpm7.4 -F
