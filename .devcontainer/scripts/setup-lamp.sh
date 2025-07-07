#!/bin/bash

# Script d'initialisation complète de l'environnement LAMP
echo "🚀 Initialisation de l'environnement LAMP..."

# Rendre tous les scripts exécutables
chmod +x /workspaces/LAMP-start/.devcontainer/scripts/*.sh 2>/dev/null || true
chmod +x /workspaces/LAMP-start/database/scripts/*.sh 2>/dev/null || true

# Variables d'environnement par défaut
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ]; then
    export MYSQL_ADMIN_USER="admin"
    export MYSQL_ADMIN_PASSWORD="admin123"
fi

echo "📝 Configuration avec utilisateur: $MYSQL_ADMIN_USER"

# 1. CONFIGURATION MYSQL
echo "🔧 Configuration MySQL..."

# Vérifier si MySQL est déjà configuré
if mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ MySQL déjà configuré"
else
    # Démarrer MariaDB et attendre qu'il soit prêt
    sudo service mariadb start >/dev/null 2>&1
    for i in {1..15}; do
        if sudo mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
            echo "✅ MariaDB prêt"
            break
        fi
        if [ $i -eq 15 ]; then
            echo "❌ Erreur: MariaDB n'a pas démarré"
            exit 1
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
        echo "✅ MySQL configuré"
    else
        echo "❌ Erreur configuration MySQL"
        exit 1
    fi
fi

# 2. INSTALLATION ET CONFIGURATION PHPMYADMIN
echo "🌐 Installation et configuration phpMyAdmin..."

# Supprimer l'ancienne installation si elle existe
if [ -d "/usr/src/phpmyadmin" ]; then
    sudo rm -rf /usr/src/phpmyadmin
fi

# Télécharger et installer phpMyAdmin
cd /tmp
wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
if [ $? -eq 0 ]; then
    tar xzf phpMyAdmin-latest-all-languages.tar.gz
    sudo mv phpMyAdmin-*-all-languages /usr/src/phpmyadmin
    rm phpMyAdmin-latest-all-languages.tar.gz
    echo "✅ phpMyAdmin téléchargé et installé"
else
    echo "❌ Erreur téléchargement phpMyAdmin"
    exit 1
fi

# Configurer phpMyAdmin
sudo cp /usr/src/phpmyadmin/config.sample.inc.php /usr/src/phpmyadmin/config.inc.php

# Créer la configuration complète
sudo tee /usr/src/phpmyadmin/config.inc.php > /dev/null << EOF
<?php
/* Configuration phpMyAdmin générée automatiquement */
\$cfg['blowfish_secret'] = '$(openssl rand -base64 32)';
\$cfg['DefaultLang'] = 'fr';
\$cfg['ServerDefault'] = 1;

\$i = 0;
\$i++;
\$cfg['Servers'][\$i]['verbose'] = 'Serveur MySQL Local';
\$cfg['Servers'][\$i]['host'] = '127.0.0.1';
\$cfg['Servers'][\$i]['port'] = '';
\$cfg['Servers'][\$i]['socket'] = '';
\$cfg['Servers'][\$i]['auth_type'] = 'config';
\$cfg['Servers'][\$i]['user'] = '${MYSQL_ADMIN_USER}';
\$cfg['Servers'][\$i]['password'] = '${MYSQL_ADMIN_PASSWORD}';
\$cfg['Servers'][\$i]['AllowNoPassword'] = true;

\$cfg['UploadDir'] = '/usr/src/phpmyadmin/upload';
\$cfg['SaveDir'] = '/usr/src/phpmyadmin/save';
\$cfg['TempDir'] = '/usr/src/phpmyadmin/tmp';
?>
EOF

# Créer les dossiers nécessaires
sudo mkdir -p /usr/src/phpmyadmin/{tmp,upload,save}

# Corriger les permissions pour phpMyAdmin
sudo chown -R vscode:vscode /usr/src/phpmyadmin
sudo chmod -R 755 /usr/src/phpmyadmin
sudo chmod -R 777 /usr/src/phpmyadmin/{tmp,upload,save}

echo "✅ phpMyAdmin et mysql configurés"
echo "✅ MySQL: mysql -u $MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASSWORD"
echo "✅ Environnement LAMP prêt!"
