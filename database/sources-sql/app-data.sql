-- Dump de la base de données applicative
-- Ce fichier contient la structure et les données de la base de données métier
-- Doit commencer par : USE nom_de_votre_base;
-- Les scripts de sauvegarde et restauration utilisent ce fichier


-- Exemple de structure (à remplacer par votre vrai dump)
-- CREATE TABLE exemple_table (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     nom VARCHAR(100) NOT NULL,
--     type VARCHAR(50),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- INSERT INTO exemple_table (nom, type) VALUES 
-- ('Exemple 1', 'Type A'),
-- ('Exemple 2', 'Type B');

CREATE TABLE IF NOT EXISTS `exemple_table` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `type` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO `exemple_table` (`nom`, `type`) VALUES 
('Exemple 1', 'Type A'),
('Exemple 2', 'Type B');