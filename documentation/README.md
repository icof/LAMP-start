# Documentation du projet

Ce dossier contient la documentation générée automatiquement du projet LAMP-start.

## Génération automatique

La documentation est générée automatiquement via GitHub Actions lors des push sur la branche main qui modifient les fichiers PHP dans le dossier `site/`.

## Génération manuelle

Pour générer la documentation localement :

```bash
# Depuis la racine du projet avec le fichier de configuration
php documentation/tools/phpDocumentor.phar run -c documentation/tools/phpdoc.xml

# Ou avec les paramètres en ligne de commande
php documentation/tools/phpDocumentor.phar run -d ./site -t ./documentation/generated
```

## Configuration

La configuration de phpDocumentor se trouve dans le fichier `documentation/tools/phpdoc.xml`.

## Consultation

Après génération, ouvrez le fichier `documentation/generated/index.html` dans votre navigateur pour consulter la documentation.
