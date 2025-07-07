#!/bin/bash

# Script d'initialisation de MySQL pour l'environnement de développement
echo "Configuration MySQL..."

# Variables d'environnement par défaut
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
    export MYSQL_ADMIN_USER="admin"
    export MYSQL_ADMIN_PASSWORD="admin123"
fi

# Vérifier si MySQL est déjà configuré
if mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "MySQL déjà configuré avec l'utilisateur $MYSQL_ADMIN_USER"
    exit 0
fi

# Démarrer MariaDB et attendre qu'il soit prêt
sudo service mariadb start >/dev/null 2>&1
for i in {1..10}; do
    if sudo mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Créer l'utilisateur admin
sudo mysql -u root -e "
    CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'localhost' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
" 2>/dev/null

# Vérifier la configuration
if mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "MySQL configuré (utilisateur: $MYSQL_ADMIN_USER)"
    
    # Configurer phpMyAdmin si disponible
    if [ -d "/usr/src/phpmyadmin" ]; then
        echo "Configuration phpMyAdmin..."
        echo "\$cfg['Servers'][\$i]['user'] = '${MYSQL_ADMIN_USER}';" | sudo tee -a /usr/src/phpmyadmin/config.inc.php >/dev/null
        echo "\$cfg['Servers'][\$i]['password'] = '${MYSQL_ADMIN_PASSWORD}';" | sudo tee -a /usr/src/phpmyadmin/config.inc.php >/dev/null
        echo "phpMyAdmin configuré!"
    fi
else
    echo "Erreur configuration MySQL"
    exit 1
fi