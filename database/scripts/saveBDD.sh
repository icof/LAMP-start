#!/bin/bash
echo "Exécution du script saveDBB.sh..."

# Vérifier si les variables d'environnement sont définies
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ] || [ -z "$DATABASE_NAME" ]; then
    echo "Les variables d'environnement MYSQL_ADMIN_USER, MYSQL_ADMIN_PASSWORD et DATABASE_NAME doivent être définies."
    exit 1
fi

# Variables de configuration depuis l'environnement
DB_NAME="$DATABASE_NAME"
DB_USER="$MYSQL_ADMIN_USER"
DB_PASSWORD="$MYSQL_ADMIN_PASSWORD"
BACKUP_DIR="database/sources-sql"

# Exécuter le dump de la base de données et ajouter la commande USE au début
{
  echo "USE $DB_NAME;"
  mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
} > "$BACKUP_DIR/app-data.sql"

# Vérifier si la commande s'est exécutée avec succès
if [ $? -eq 0 ]; then
  echo "Sauvegarde de la base de données '$DB_NAME' réussie : $BACKUP_DIR/app-data.sql"
else
  echo "Erreur lors de la sauvegarde de la base de données"
  exit 1
fi