# Config de Codespace LAMP


## Arborescence du dépôt

Voici l'arborescence du dépôt et le rôle des différents composants. Les fichiers et dossiers à modifier sont en gras :

├── .devcontainer/ # config du codespace
|  ├── devcontainer.json # Configuration du Dev Container pour VS Code
|  ├── setup-lamp.sh # Script de configuration de l'environnement LAMP (MariaDB, PhpMyAdmin)
|  └── Dockerfile # Dockerfile pour construire l'image du Dev Container serveur php avec mariadb
├── .github/ # config pour les actions GitHub 
|  ├── dependabot.yml # Configuration pour Dependabot, qui gère les mises à jour des dépendances
|  └── workflows/ # (Optionnel) Workflows GitHub Actions pour CI/CD automatisés
├── .vscode/ # config pour XDebug et parametres de vscode
├── database # scripts pour la BDD
|  ├── scripts # contient 3 scripts bash : 1 pour initialiser la BDD métier (avec ses utilisateurs système), 1 pour sauver la bdd métier du codespace et 1 pour la recharger à partir du .sql présent dans le dépot
|  └── sources-sql # fichiers SQL pour contruire la BDD métier, ses utilisateurs et ses données 
├── site # Dossier racine du serveur web
├── start.sh # Script de lancement pour démarrer le service mariadb et les instances web du site et de phpMyAdmin.
└── stop.sh # Script pour arreter le service mariadb et les instances web du site et de phpMyAdmin.


## Configuration du Codespace et lancement de l'application

Ce dépôt est configuré pour fonctionner avec les Codespaces de GitHub et les Dev Containers de Visual Studio Code. Suivez les étapes ci-dessous pour configurer votre environnement de développement.

!important! 
Pour être executables, les scripts bash executés dans le codespace (start.sh, stop.sh, initBDD.sh, ...) doivent avoir les bonnes permissions.

1. Utilisez la commande ```ls -l``` pour afficher les permissions des fichiers dans le répertoire contenant vos scripts bash.
Cela affichera les permissions actuelles des fichiers. Les scripts doivent avoir l'autorisation d'exécution (x) pour être exécutables.

2. Ajouter les droits d'exécution
Si les scripts n'ont pas les bonnes permissions, utilisez la commande chmod pour leur ajouter les droits d'exécution :
```chmod +x ./start.sh ./stop.sh ./database/scripts/*.sh```


### Utilisation avec GitHub Codespaces
1. **Créez un codespace pour ouvrir ce dépot** :
   - Cliquez sur le bouton "Code" dans GitHub et sélectionnez "Open with Codespaces".
   - Si vous n'avez pas encore de Codespace, cliquez sur "New Codespace".

   Le Codespace ainsi créé contient toutes les configurations nécessaires pour démarrer le développement.

### Serveur php et service mariadb (avec la base métier)

1. **Pour lancer les services** :
   - Dans le terminal, exécutez le script `start.sh` :
     ```bash
     ./start.sh
     ```
   Ce script démarre le serveur PHP intégré sur le port 8000, démarre mariadb et crée la base métier depuis le script renseigné (mettre à jour en fonction du projet).

2. **Ouvrir le service php dans un navigateur** :
   - Accédez à `http://localhost:8000` pour voir la page d'accueil de l'API.

3. **Accèder à la BDD** :
   - En mode commande depuis le client mysql en ligne de commande
   Exemple : 
      ```bash
      mysql -u mediateq-web -p
      ```
   - En client graphique avec l'extension Database dans le codespace (Host:127.0.0.1)

   - avec phpMyAdmin sur le port 8080

4. **initialiser la BDD** :
   - Au premier démarrage, créez la bdd métier avec le fichier sql 
      ```bash
      ./database/scripts/initBDD.sh 
      ```

5. **Sauver et mettre à jour la BDD** :
   - A chaque fois que vous avez fait des modifs significatives dans la BDD métier, lancer le script bash saveBDD pour écraser le fichier sql actuel de la bdd par votre sauvegarde (puis pensez à push sur le distant pour vos collaborateurs)
      ```bash
      ./database/scripts/saveBDD.sh 
      ```
   - Si des modifs ont été faites à la BDD et que vous avez récupéré du dépot distant (pull) une version mise à jour du script de la BDD métier, lancer le script bash reloadBDD pour écraser la bdd actuelle de votre codespace par celle du script récupéré.
      ```bash
      ./database/scripts/reloadBDD.sh 
      ```

## Utilisation de XDebug

Ce Codespace contient XDebug pour le débogage PHP. 

1. **Exemple de déboguage avec Visual Studio Code** :
   - Ouvrez le panneau de débogage en cliquant sur l'icône de débogage dans la barre latérale ou en utilisant le raccourci clavier `Ctrl+Shift+D`.
   - Sélectionnez la configuration "Listen for XDebug" et cliquez sur le bouton de lancement (icône de lecture).
   - Ouvrez un fichier php
   - Ajouter un point d'arrêt.
   - Solicitez dans le navigateur une page qui appelle le traitement
   - Une fois le point d'arrêt atteint, essayez de survoler les variables, d'examiner les variables locales, etc.

[Tuto Grafikart : Xdebug, l'exécution pas à pas ](https://grafikart.fr/tutoriels/xdebug-breakpoint-834)


## Tests unitaires

Ce projet utilise PHPUnit pour les tests unitaires.

1. ** Installer les dépendances **
Pour exécuter les tests unitaires, assurez-vous que les dépendances nécessaires sont installées via Composer en executant :
```bash
composer install
```
2. ** Lancer les tests **
Une fois les dépendances installées, lancez les tests avec la commande suivante :
```bash
vendor/bin/phpunit --testdox tests/
```
Cela exécutera tous les tests définis dans le projet et affichera les résultats dans le terminal.

3. ** Ajouter de nouveaux tests **
Pour ajouter un nouveau test :
- Créez un fichier de test dans le répertoire approprié (par exemple, tests/modele/NouveauModeleTest.php).

- Assurez-vous que le fichier suit la convention de nommage `NomClasseTest.php` et que la classe de test étend `PHPUnit\Framework\TestCase`.

Exemple de test unitaire simple :

```php
<?php

use PHPUnit\Framework\TestCase;

class ExempleTest extends TestCase
{
   public function testAddition()
   {
      $this->assertEquals(4, 2 + 2);
   }
}
```

Une fois le test ajouté, relancez la commande PHPUnit pour vérifier son bon fonctionnement.

## Documentation

**phpDocumentor** est un outil qui permet de générer automatiquement la documentation technique de votre code PHP à partir des commentaires présents dans vos fichiers source.

**Fonctionnement :**
- *Commentaires PHPDoc* : Vous commentez vos classes, fonctions et propriétés avec des blocs de commentaires spéciaux (PHPDoc).
- *Génération automatique* : phpDocumentor analyse ces commentaires et crée une documentation HTML structurée et navigable.
- *Personnalisation* : Vous pouvez choisir le dossier à documenter (```-d ./site```) et le dossier de sortie (```-t ./documentation```).

**Exemple de commentaire PHPDoc :**
```php
<?php
/**
 * Additionne deux nombres.
 *
 * @param int $a
 * @param int $b
 * @return int
 */
function addition(int $a, int $b) : int {
    return $a + $b;
}
```
plus d'infos sur [le guide phpDocumentor](https://docs.phpdoc.org/guide/getting-started/what-is-a-docblock.html#what-is-a-docblock)

**Commande de génération :**
```
php phpDocumentor.phar run -d ./site -t ./documentation
```
- ```-d ./site``` : dossier contenant le code à documenter.
- ```-t ./documentation``` : dossier où sera générée la documentation HTML.

**Résultat :**
Après exécution, ouvrez le fichier index.html sur le serveur executé sur le port 8001 dans un navigateur pour consulter la documentation de votre projet.
