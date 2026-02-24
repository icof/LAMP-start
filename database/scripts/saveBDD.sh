#!/bin/bash
echo "Exécution du script saveBDD.sh..."

# Charger la configuration locale (valeurs par défaut) et permettre la surcharge par variables d'environnement
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Résolution des paramètres (env > config par défaut)
WEBAPP_DB_NAME="$WEBAPP_DB_NAME"
DB_USER="${MYSQL_ADMIN_USER:-$MYSQL_ADMIN_USER_DEFAULT}"
DB_PASSWORD="${MYSQL_ADMIN_PASSWORD:-$MYSQL_ADMIN_PASSWORD_DEFAULT}"

# Vérifier si les paramètres nécessaires sont présents
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$WEBAPP_DB_NAME" ]; then
  echo "Les paramètres DB_USER, DB_PASSWORD et WEBAPP_DB_NAME doivent être renseignés (via variables d'env ou config.sh)."
  exit 1
fi

BACKUP_DIR="database/sources-sql"
BACKUP_FILE="$BACKUP_DIR/${WEBAPP_DB_NAME}.sql"

# Exécuter le dump de la base de données et ajouter la commande USE au début
{
  echo "USE $WEBAPP_DB_NAME;"
  mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$WEBAPP_DB_NAME"
} > "$BACKUP_FILE"

# Vérifier si la commande s'est exécutée avec succès
if [ $? -eq 0 ]; then
  echo "Sauvegarde de la base de données '$WEBAPP_DB_NAME' réussie : $BACKUP_FILE"
else
  echo "Erreur lors de la sauvegarde de la base de données"
  exit 1
fi