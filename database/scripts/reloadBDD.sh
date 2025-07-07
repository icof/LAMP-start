#!/bin/bash
echo "Exécution du script reloadDBB.sh..."

# Variables de configuration
BACKUP_DIR="database/sources-sql" # Chemin vers le répertoire contenant les fichiers de sauvegarde
BACKUP_FILE="$BACKUP_DIR/app-data.sql" # Nom du fichier de sauvegarde à restaurer

# Vérifier si les variables d'environnement sont bien définies dans devcontainer.json
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ] || [ -z "$DATABASE_NAME" ]; then
  echo "Les variables d'environnement MYSQL_ADMIN_USER, MYSQL_ADMIN_PASSWORD et DATABASE_NAME doivent être définies dans devcontainer.json."
  exit 1
fi

# Variables de configuration utilisant les variables d'environnement
DB_USER="$MYSQL_ADMIN_USER" # Nom d'utilisateur de la base de données
DB_PASSWORD="$MYSQL_ADMIN_PASSWORD" # Mot de passe de l'utilisateur de la base de données
DB_NAME="$DATABASE_NAME" # Nom de la base de données

# Vérifier si le fichier de sauvegarde existe
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Le fichier de sauvegarde $BACKUP_FILE n'existe pas."
  exit 1
fi

# Vider toutes les tables de la base de données existante
echo "Vidage de toutes les tables de la base de données existante $DB_NAME..."
TABLES=$(mysql -u $DB_USER -p$DB_PASSWORD -N -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '$DB_NAME';")
for TABLE in $TABLES; do
  mysql -u $DB_USER -p$DB_PASSWORD -e "SET FOREIGN_KEY_CHECKS = 0; DROP TABLE IF EXISTS $TABLE; SET FOREIGN_KEY_CHECKS = 1;" $DB_NAME
done

# Restaurer la base de données à partir du fichier de sauvegarde
echo "Restauration de la base de données $DB_NAME à partir de $BACKUP_FILE..."
mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < $BACKUP_FILE

echo "La base de données $DB_NAME a été remplacée avec succès."