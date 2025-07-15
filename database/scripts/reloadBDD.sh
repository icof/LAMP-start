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

# Vérifier si la base de données existe
echo "Vérification de l'existence de la base de données $DB_NAME..."
DB_EXISTS=$(mysql -u $DB_USER -p$DB_PASSWORD -N -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME';")

if [ "$DB_EXISTS" -eq 0 ]; then
  echo "La base de données $DB_NAME n'existe pas. Création avec initBDD.sh..."
  # Appeler le script d'initialisation
  if [ -f "database/scripts/initBDD.sh" ]; then
    bash database/scripts/initBDD.sh
    if [ $? -eq 0 ]; then
      echo "Base de données $DB_NAME créée avec succès."
    else
      echo "Erreur lors de la création de la base de données."
      exit 1
    fi
  else
    echo "Erreur : le script initBDD.sh n'a pas été trouvé."
    exit 1
  fi
else
  echo "La base de données $DB_NAME existe déjà. Suppression et recréation..."
  
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
fi