#!/bin/bash
echo "Exécution du script reloadBDD.sh..."

# Charger la configuration locale (valeurs par défaut) et permettre la surcharge par variables d'environnement
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Résolution des paramètres (nom de BDD issu uniquement de config.sh)
WEBAPP_DB_NAME="$WEBAPP_DB_NAME"
DB_USER="${MYSQL_ADMIN_USER:-$MYSQL_ADMIN_USER_DEFAULT}"
DB_PASSWORD="${MYSQL_ADMIN_PASSWORD:-$MYSQL_ADMIN_PASSWORD_DEFAULT}"

# Vérifier si les paramètres nécessaires sont présents
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$WEBAPP_DB_NAME" ]; then
  echo "Les paramètres DB_USER, DB_PASSWORD et WEBAPP_DB_NAME doivent être renseignés (via variables d'env ou config.sh)."
  exit 1
fi

# Variables de configuration
BACKUP_DIR="database/sources-sql" # Chemin vers le répertoire contenant les fichiers de sauvegarde
BACKUP_FILE="$BACKUP_DIR/${WEBAPP_DB_NAME}.sql" # Fichier de sauvegarde à restaurer

# Vérifier si le fichier de sauvegarde existe
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Le fichier de sauvegarde $BACKUP_FILE n'existe pas."
  exit 1
fi

# Vérifier si la base de données existe
echo "Vérification de l'existence de la base de données $WEBAPP_DB_NAME..."
DB_EXISTS=$(mysql -u $DB_USER -p$DB_PASSWORD -N -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '$WEBAPP_DB_NAME';")

if [ "$DB_EXISTS" -eq 0 ]; then
  echo "La base de données $WEBAPP_DB_NAME n'existe pas. Création avec initBDD.sh..."
  # Appeler le script d'initialisation
  if [ -f "database/scripts/initBDD.sh" ]; then
    bash database/scripts/initBDD.sh
    if [ $? -eq 0 ]; then
      echo "Base de données $WEBAPP_DB_NAME créée avec succès."
    else
      echo "Erreur lors de la création de la base de données."
      exit 1
    fi
  else
    echo "Erreur : le script initBDD.sh n'a pas été trouvé."
    exit 1
  fi
else
  echo "La base de données $WEBAPP_DB_NAME existe déjà. Suppression et recréation..."
  
  # Vider toutes les tables de la base de données existante
  echo "Vidage de toutes les tables de la base de données existante $WEBAPP_DB_NAME..."
  TABLES=$(mysql -u $DB_USER -p$DB_PASSWORD -N -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '$WEBAPP_DB_NAME';")
  for TABLE in $TABLES; do
    mysql -u $DB_USER -p$DB_PASSWORD -e "SET FOREIGN_KEY_CHECKS = 0; DROP TABLE IF EXISTS $TABLE; SET FOREIGN_KEY_CHECKS = 1;" $WEBAPP_DB_NAME
  done

  # Restaurer la base de données à partir du fichier de sauvegarde
  echo "Restauration de la base de données $WEBAPP_DB_NAME à partir de $BACKUP_FILE..."
  mysql -u $DB_USER -p$DB_PASSWORD $WEBAPP_DB_NAME < $BACKUP_FILE
  
  echo "La base de données $WEBAPP_DB_NAME a été remplacée avec succès."
fi