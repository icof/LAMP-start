-- Script d'initialisation générique de la base de données
-- Le nom de la base est défini via la variable d'environnement DATABASE_NAME dans devcontainer.json
-- L'utilisateur applicatif est défini via WEBAPP_USER et WEBAPP_PASSWORD
-- Ce script sera traité par les scripts bash qui remplaceront les placeholders

-- Création de la base de données
DROP DATABASE IF EXISTS `__DATABASE_NAME__`;

CREATE DATABASE IF NOT EXISTS `__DATABASE_NAME__` CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Sélection de la base de données
USE `__DATABASE_NAME__`;

-- Utilisateur applicatif paramétrable
DROP USER IF EXISTS '__WEBAPP_USER__' @'%';

CREATE USER '__WEBAPP_USER__' @'%' IDENTIFIED BY '__WEBAPP_PASSWORD__';

GRANT
SELECT,
INSERT
,
UPDATE,
DELETE ON __DATABASE_NAME__.* TO '__WEBAPP_USER__' @'%';

GRANT CREATE,
DROP,
ALTER ON __DATABASE_NAME__.* TO '__WEBAPP_USER__' @'%';

-- Flush des privilèges
FLUSH PRIVILEGES;