#!/bin/bash

# Script d'initialisation de MySQL qui utilise les variables d'environnement
echo "Initialisation de MySQL avec les variables d'environnement..."

# Utilise les variables d'environnement définies dans devcontainer.json
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
    echo "Les variables d'environnement MYSQL_ADMIN_USER et MYSQL_ADMIN_PASSWORD doivent être définies."
    echo "Utilisation des valeurs par défaut pour l'environnement de développement."
    export MYSQL_ADMIN_USER="admin"
    export MYSQL_ADMIN_PASSWORD="admin123"
fi

echo "Configuration MySQL avec utilisateur: $MYSQL_ADMIN_USER"

# Vérifier si MySQL est déjà configuré
if mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "✓ MySQL est déjà configuré avec l'utilisateur $MYSQL_ADMIN_USER"
    exit 0
fi

# S'assurer que MariaDB est démarré
echo "Démarrage de MariaDB..."
sudo service mariadb start >/dev/null 2>&1

# Attendre que MariaDB soit prêt
echo "Attente du démarrage de MariaDB..."
for i in {1..30}; do
    if sudo mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        echo "MariaDB est prêt"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Timeout: MariaDB n'a pas démarré dans les 30 secondes"
        exit 1
    fi
    sleep 1
done

# Créer l'utilisateur admin avec sudo mysql (car root utilise unix_socket)
echo "Création/mise à jour de l'utilisateur admin..."
sudo mysql -u root -e "
    CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    ALTER USER '${MYSQL_ADMIN_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    ALTER USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'localhost' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
" 2>/dev/null

# Vérifier que la connexion fonctionne
echo "Vérification de la connexion..."
if mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" -e "SELECT 'Configuration reussie' as status;" 2>/dev/null; then
    echo "✓ MySQL configuré avec succès!"
    echo "  Utilisateur: $MYSQL_ADMIN_USER"
    echo "  Mot de passe: $MYSQL_ADMIN_PASSWORD"
    
    # Configurer phpMyAdmin si disponible
    if [ -d "/usr/src/phpmyadmin" ]; then
        echo "Configuration de phpMyAdmin..."
        echo "\$cfg['Servers'][\$i]['user'] = '${MYSQL_ADMIN_USER}';" | sudo tee -a /usr/src/phpmyadmin/config.inc.php >/dev/null
        echo "\$cfg['Servers'][\$i]['password'] = '${MYSQL_ADMIN_PASSWORD}';" | sudo tee -a /usr/src/phpmyadmin/config.inc.php >/dev/null
        echo "✓ phpMyAdmin configuré!"
    fi
    
    echo ""
    echo "Pour vous connecter à MySQL:"
    echo "  mysql -u $MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASSWORD"
    echo "  ou pour root:"
    echo "  sudo mysql -u root"
else
    echo "✗ Erreur: La configuration a échoué"
    exit 1
fi

echo "Initialisation terminée!"
