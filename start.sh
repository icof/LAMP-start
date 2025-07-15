#!/bin/bash
# script pour démarrer les serveurs PHP et MariaDB

# Définir les chemins vers les dossiers des sites
WEB_DIR="site" # Chemin vers le dossier contenant les fichiers du site web
phpMyAdmin_DIR="/usr/src/phpmyadmin" # Chemin vers le dossier phpMyAdmin installé dans le conteneur

# Créer le répertoire /run/mysqld si nécessaire et définir les permissions
if [ ! -d /run/mysqld ]; then
    echo "Création du répertoire /run/mysqld..."
    sudo mkdir -p /run/mysqld
    sudo chown mysql:mysql /run/mysqld
fi

# Démarrer le service MariaDB
echo "Démarrage du service MariaDB..."
sudo service mariadb start

# Fonction générique pour vérifier si un port est utilisé
is_port_in_use() {
    # Utilise lsof pour vérifier si le port spécifié est en cours d'utilisation
    lsof -i:$1 > /dev/null # teste si le port $1 est utilisé et redirige la sortie standard et la sortie d'erreur vers /dev/null 
    return $? # Retourne le code de sortie de la commande lsof -> 0 si le port est utilisé
}

# Démarrage du serveur PHP pour le dossier web
WEB_PORT=8000
if is_port_in_use $WEB_PORT; then
    echo "Le serveur PHP pour le dossier web est déjà démarré sur le port $WEB_PORT"
else
    echo "Démarrage du serveur PHP sur http://0.0.0.0:$WEB_PORT depuis $WEB_DIR"
    php -S 0.0.0.0:$WEB_PORT -t $WEB_DIR &
fi

# Démarrage du serveur PHP pour phpMyAdmin
PHPMYADMIN_PORT=8080
if is_port_in_use $PHPMYADMIN_PORT; then
    echo "Le serveur PHP pour phpMyAdmin est déjà démarré sur le port $PHPMYADMIN_PORT"
else
    echo "Démarrage du serveur PHP pour phpMyAdmin sur http://0.0.0.0:$PHPMYADMIN_PORT"
    php -S 0.0.0.0:$PHPMYADMIN_PORT -t $phpMyAdmin_DIR &
fi