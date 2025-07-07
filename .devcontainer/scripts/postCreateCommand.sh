#!/bin/bash

# Script d'initialisation de l'infrastructure LAMP
echo "Initialisation de l'infrastructure LAMP..."

# Rendre les scripts exécutables
chmod +x /workspaces/LAMP-start/.devcontainer/scripts/*.sh
chmod +x /workspaces/LAMP-start/database/scripts/*.sh

# Initialiser MySQL
bash /workspaces/LAMP-start/.devcontainer/scripts/init-mysql.sh

# Démarrer les services
sudo service apache2 start >/dev/null 2>&1
sudo service mariadb start >/dev/null 2>&1

echo ""
echo "Infrastructure LAMP prête!"
echo "   Apache: http://localhost"
echo "   MySQL: mysql -u admin -padmin123"
echo ""
echo "Pour initialiser votre base de données:"
echo "   bash database/scripts/initBDD.sh"