# constuction à partir de l'image de base https://hub.docker.com/r/microsoft/devcontainers-php et la version PHP 8.3
FROM mcr.microsoft.com/devcontainers/php:8.3

RUN \
    # Met à jour la liste des paquets
    apt-get update \
    # Installe MariaDB et wget (node, npm, php, composer sont déjà présents dans l'image de base)
    && apt-get install -y mariadb-server wget \
    # Nettoie le cache des paquets pour alléger l'image
    && rm -rf /var/lib/apt/lists/* \
    # Installe les extensions PHP nécessaires pour MariaDB/MySQL
    && docker-php-ext-install mysqli pdo pdo_mysql

# Expose les ports nécessaires
EXPOSE 3306 8000 8001 8080

# Démarre le serveur MySQL
CMD ["mysqld"]
