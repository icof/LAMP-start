#!/bin/bash

# Script d'initialisation MySQL pour résoudre le problème d'authentification root
echo "Résolution du problème d'authentification MySQL..."

# Variables d'environnement avec valeurs par défaut
export MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-"admin"}
export MYSQL_ADMIN_PASSWORD=${MYSQL_ADMIN_PASSWORD:-"admin123"}

echo "Configuration avec utilisateur: $MYSQL_ADMIN_USER"

# Redémarrer MariaDB en mode sans authentification pour la configuration
echo "Redémarrage de MariaDB en mode configuration..."
sudo service mariadb stop
sleep 2

# Démarrer MariaDB avec skip-grant-tables temporairement
echo "Démarrage de MariaDB en mode configuration..."
sudo mysqld_safe --skip-grant-tables --skip-networking &
MYSQL_PID=$!

# Attendre que MySQL soit prêt
echo "Attente du démarrage..."
sleep 5

# Vérifier que MySQL est prêt
for i in {1..10}; do
    if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        echo "MySQL est prêt"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "Erreur: MySQL n'a pas démarré"
        exit 1
    fi
    sleep 1
done

# Configurer l'authentification
echo "Configuration de l'authentification..."
mysql -u root << EOF
-- Utiliser la base mysql
USE mysql;

-- Configurer root avec mot de passe standard (pas de socket)
UPDATE user SET plugin = 'mysql_native_password' WHERE User = 'root';
UPDATE user SET Password = PASSWORD('${MYSQL_ADMIN_PASSWORD}') WHERE User = 'root';

-- Créer l'utilisateur admin
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';

-- Accorder tous les privilèges
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;

-- Appliquer les changements
FLUSH PRIVILEGES;
EOF

# Arrêter le processus temporaire
echo "Arrêt du processus temporaire..."
sudo kill $MYSQL_PID 2>/dev/null || true
sudo pkill -f mysqld_safe 2>/dev/null || true
sudo pkill -f mysqld 2>/dev/null || true
sleep 3

# Redémarrer MariaDB normalement
echo "Redémarrage de MariaDB..."
sudo service mariadb start
sleep 3

# Vérifier la configuration
echo "Vérification de la configuration..."
if mysql -u "${MYSQL_ADMIN_USER}" -p"${MYSQL_ADMIN_PASSWORD}" -e "SELECT 'Configuration réussie!' as status;" 2>/dev/null; then
    echo "✓ MySQL configuré avec succès!"
    echo "  Utilisateur: ${MYSQL_ADMIN_USER}"
    echo "  Mot de passe: ${MYSQL_ADMIN_PASSWORD}"
    
    # Tester aussi root
    if mysql -u root -p"${MYSQL_ADMIN_PASSWORD}" -e "SELECT 'Root OK!' as status;" 2>/dev/null; then
        echo "✓ Root également configuré avec succès!"
    fi
else
    echo "✗ Erreur: La configuration a échoué"
    echo "Essai de diagnostic..."
    mysql -u root -e "SELECT User, Host, plugin FROM mysql.user;" 2>/dev/null || echo "Impossible de se connecter"
    exit 1
fi

echo "Initialisation terminée!"
