#!/bin/bash

# Script d'initialisation de MySQL qui utilise les variables d'environnement
echo "Initialisation de MySQL avec les variables d'environnement..."


# Utilise les variables d'environnement définies dans devcontainer.json
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
    echo "Les variables d'environnement MYSQL_ADMIN_USER et MYSQL_ADMIN_PASSWORD doivent être définies dans devcontainer.json."
    exit 1
fi

# Démarrer MySQL
service mariadb start

# Créer l'utilisateur admin
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Configurer phpMyAdmin avec les variables d'environnement
echo "Configuration de phpMyAdmin..."
echo "\$cfg['Servers'][\$i]['user'] = '${MYSQL_ADMIN_USER}';" >> /usr/src/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['password'] = '${MYSQL_ADMIN_PASSWORD}';" >> /usr/src/phpmyadmin/config.inc.php

echo "MySQL et phpMyAdmin configurés avec succès!"
