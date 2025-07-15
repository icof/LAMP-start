-- Script d'initialisation générique de la base de données
-- Le nom de la base est défini via la variable d'environnement DATABASE_NAME dans devcontainer.json
-- Ce script sera traité par les scripts bash qui remplaceront le placeholder

-- Création de la base de données
DROP DATABASE IF EXISTS `__DATABASE_NAME__`;
CREATE DATABASE IF NOT EXISTS `__DATABASE_NAME__`
CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Sélection de la base de données
USE `__DATABASE_NAME__`;

-- Exemple d'utilisateur applicatif (à adapter selon vos besoins)
DROP USER IF EXISTS 'app_user'@'%';
CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON __DATABASE_NAME__.* TO 'app_user'@'%';

-- Flush des privilèges
FLUSH PRIVILEGES;