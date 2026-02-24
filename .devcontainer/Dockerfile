# constuction à partir de l'image de base https://hub.docker.com/r/microsoft/devcontainers-php et la version PHP 8.3
FROM mcr.microsoft.com/devcontainers/php:dev-8.3


RUN \
    # Met à jour la liste des paquets
    apt-get update \
    # Installe MariaDB, wget et les outils pour Node.js
    && apt-get install -y mariadb-server wget curl gpg \
    # Installe les extensions PHP nécessaires pour MariaDB/MySQL
    && docker-php-ext-install mysqli pdo pdo_mysql \
    # Installe Node.js 20 (requis par SonarQube for VS Code)
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    # Nettoie le cache des paquets pour alléger l'image
    && rm -rf /var/lib/apt/lists/*