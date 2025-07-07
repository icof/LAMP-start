#!/bin/bash

# Script d'initialisation MySQL - Version MariaDB compatible
echo "Initialisation MySQL/MariaDB..."

# Variables d'environnement avec valeurs par défaut
export MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:-"admin"}
export MYSQL_ADMIN_PASSWORD=${MYSQL_ADMIN_PASSWORD:-"admin123"}

echo "Configuration avec utilisateur: $MYSQL_ADMIN_USER"

# Redémarrer MariaDB en mode sans authentification
echo "Redémarrage de MariaDB en mode configuration..."
sudo service mariadb stop
sleep 2

# Démarrer MariaDB avec skip-grant-tables
echo "Démarrage de MariaDB en mode configuration..."
sudo mysqld_safe --skip-grant-tables --skip-networking &
MYSQL_PID=$!
sleep 5

# Configurer l'authentification avec les commandes correctes pour MariaDB
echo "Configuration de l'authentification..."
mysql -u root << 'EOF'
-- Utiliser la base mysql
USE mysql;

-- Pour MariaDB, on utilise SET PASSWORD
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('admin123');

-- Créer l'utilisateur admin
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin123';

-- Accorder tous les privilèges
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;

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
if mysql -u "admin" -p"admin123" -e "SELECT 'Configuration réussie!' as status;" 2>/dev/null; then
    echo "✓ MySQL configuré avec succès!"
    echo "  Utilisateur: admin"
    echo "  Mot de passe: admin123"
    
    # Tester aussi root
    if mysql -u root -p"admin123" -e "SELECT 'Root OK!' as status;" 2>/dev/null; then
        echo "✓ Root également configuré avec succès!"
    else
        echo "! Root nécessite peut-être sudo mysql"
    fi
    
    # Afficher les utilisateurs configurés
    echo "Utilisateurs configurés:"
    mysql -u "admin" -p"admin123" -e "SELECT User, Host FROM mysql.user WHERE User IN ('root', 'admin');" 2>/dev/null || true
    
else
    echo "✗ Erreur: La configuration a échoué"
    echo "Essai de diagnostic..."
    
    # Essayer avec sudo
    if sudo mysql -u root -e "SELECT User, Host FROM mysql.user;" 2>/dev/null; then
        echo "Root fonctionne avec sudo, créons l'utilisateur admin:"
        sudo mysql -u root -e "
            CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';
            CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin123';
            GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
            GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;
        "
        
        if mysql -u "admin" -p"admin123" -e "SELECT 'Admin créé!' as status;" 2>/dev/null; then
            echo "✓ Utilisateur admin créé avec succès!"
        else
            echo "✗ Échec de création de l'utilisateur admin"
            exit 1
        fi
    else
        echo "✗ Impossible de se connecter même avec sudo"
        exit 1
    fi
fi

echo "Initialisation terminée!"
echo ""
echo "Pour vous connecter à MySQL:"
echo "  mysql -u admin -p admin123"
echo "  ou"
echo "  sudo mysql -u root"
