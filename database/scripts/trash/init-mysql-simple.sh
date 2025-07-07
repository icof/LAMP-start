#!/bin/bash

# Script d'initialisation MySQL simplifié pour environnement de développement
echo "Initialisation MySQL pour environnement de développement..."

# Vérifier les variables d'environnement
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
    echo "Variables d'environnement manquantes. Utilisation des valeurs par défaut."
    export MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-"admin"}
    export MYSQL_ADMIN_PASSWORD=${MYSQL_ADMIN_PASSWORD:-"admin123"}
    echo "Utilisateur: $MYSQL_ADMIN_USER"
fi

# Arrêter MariaDB s'il est en cours d'exécution
echo "Arrêt de MariaDB..."
sudo service mariadb stop 2>/dev/null || true
sudo pkill -f mysqld 2>/dev/null || true
sleep 2

# Préparer les répertoires nécessaires
echo "Préparation des répertoires..."
sudo mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql
sudo chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql
sudo chmod 755 /run/mysqld /var/lib/mysql /var/log/mysql

# Initialiser la base de données si nécessaire
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de la base de données..."
    sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

# Démarrer MariaDB
echo "Démarrage de MariaDB..."
sudo service mariadb start

# Attendre que MariaDB soit prêt
echo "Attente du démarrage de MariaDB..."
timeout=30
counter=0
while [ $counter -lt $timeout ]; do
    if sudo mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        echo "MariaDB est prêt après $counter secondes"
        break
    fi
    if [ $counter -eq $((timeout-1)) ]; then
        echo "Erreur: MariaDB n'a pas démarré dans les $timeout secondes"
        exit 1
    fi
    counter=$((counter + 1))
    sleep 1
done

# Configuration de l'authentification
echo "Configuration de l'authentification..."
sudo mysql -u root << EOF
-- Configurer root avec mot de passe
UPDATE mysql.user SET Password = PASSWORD('${MYSQL_ADMIN_PASSWORD}') WHERE User = 'root';
UPDATE mysql.user SET plugin = '' WHERE User = 'root';

-- Nettoyer les utilisateurs anonymes
DELETE FROM mysql.user WHERE User = '';

-- Créer l'utilisateur admin
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';

-- Accorder tous les privilèges
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

# Vérifier la configuration
echo "Vérification de la configuration..."
if mysql -u "${MYSQL_ADMIN_USER}" -p"${MYSQL_ADMIN_PASSWORD}" -e "SELECT 'Configuration réussie!' as status;" 2>/dev/null; then
    echo "✓ MySQL configuré avec succès!"
    echo "  Utilisateur: ${MYSQL_ADMIN_USER}"
    echo "  Mot de passe: ${MYSQL_ADMIN_PASSWORD}"
    
    # Configurer phpMyAdmin si disponible
    if [ -d "/usr/src/phpmyadmin" ]; then
        echo "Configuration de phpMyAdmin..."
        sudo tee -a /usr/src/phpmyadmin/config.inc.php > /dev/null << EOF
\$cfg['Servers'][\$i]['user'] = '${MYSQL_ADMIN_USER}';
\$cfg['Servers'][\$i]['password'] = '${MYSQL_ADMIN_PASSWORD}';
EOF
        echo "✓ phpMyAdmin configuré!"
    fi
else
    echo "✗ Erreur: La configuration a échoué"
    exit 1
fi

echo "Initialisation terminée!"
