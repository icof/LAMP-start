#!/bin/bash
echo "Exécution du script initDBB.sh..."

SQL_FILE_ENV="database/sources-sql/init-BDD.sql" # chemin vers le fichier SQL contenant les commandes d'initialisation de la base de données (création de la base, utilisateurs, etc.)
SQL_FILE_BDD="database/sources-sql/app-data.sql" # chemin vers le fichier SQL contenant les structures et données de la base de données métier.

# Vérifier si les variables d'environnement sont bien définies dans devcontainer.json
if [ -z "$MYSQL_ADMIN_USER" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ] || [ -z "$DATABASE_NAME" ]; then
    echo "Les variables d'environnement MYSQL_ADMIN_USER, MYSQL_ADMIN_PASSWORD et DATABASE_NAME doivent être définies dans devcontainer.json."
    exit 1
fi

# Variables de configuration utilisant les variables d'environnement 
MYSQL_USER="${MYSQL_ADMIN_USER}" # Nom d'utilisateur de la base de données
MYSQL_PASSWORD="${MYSQL_ADMIN_PASSWORD}" # Mot de passe de l'utilisateur de la base de données
DATABASE_NAME="${DATABASE_NAME}" # Nom de la base de données

# Vérifier si les fichiers SQL existent
if [ ! -f "$SQL_FILE_ENV" ] || [ ! -f "$SQL_FILE_BDD" ]; then
    echo "Le fichier $SQL_FILE_ENV ou $SQL_FILE_BDD n'existe pas."
    exit 1
fi

# Créer un fichier temporaire avec le nom de la base remplacé
TEMP_SQL_FILE_ENV="/tmp/init-BDD-processed.sql"
sed -e "s/__DATABASE_NAME__/$DATABASE_NAME/g" \
    "$SQL_FILE_ENV" > "$TEMP_SQL_FILE_ENV"

# Créer la base de données à partir du fichier SQL traité
echo "Création de la base de données '$DATABASE_NAME' à partir de $SQL_FILE_ENV..."
mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" < "$TEMP_SQL_FILE_ENV"

# Peupler la base de données à partir du fichier SQL
echo "Peuplement de la BDD à partir de $SQL_FILE_BDD..."
mysql -u "$MYSQL_ADMIN_USER" -p"$MYSQL_ADMIN_PASSWORD" < "$SQL_FILE_BDD"

# Nettoyer le fichier temporaire
rm "$TEMP_SQL_FILE_ENV"