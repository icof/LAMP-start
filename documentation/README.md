# Documentation du projet

Ce dossier contient la documentation générée automatiquement du projet LAMP-start.

## Qu'est-ce que phpDocumentor ?

**phpDocumentor** est un outil qui permet de générer automatiquement la documentation technique de votre code PHP à partir des commentaires présents dans vos fichiers source.

### Fonctionnement

- **Commentaires PHPDoc** : Vous commentez vos classes, fonctions et propriétés avec des blocs de commentaires spéciaux (PHPDoc).
- **Génération automatique** : phpDocumentor analyse ces commentaires et crée une documentation HTML structurée et navigable.
- **Personnalisation** : Vous pouvez choisir le dossier à documenter (`-d ./site`) et le dossier de sortie (`-t ./documentation`).

### Configuration

Sur ce dépot, la configuration de phpDocumentor se trouve dans le fichier `documentation/tools/phpdoc.xml`.

Ce fichier permet de personnaliser :
- Les dossiers source à analyser
- Le dossier de destination
- Le template de documentation
- Les exclusions de fichiers
- Les paramètres de génération

### Exemple de commentaire PHPDoc

```php
<?php
/**
 * Additionne deux nombres.
 *
 * @param int $a Premier nombre
 * @param int $b Deuxième nombre
 * @return int Résultat de l'addition
 * @throws InvalidArgumentException Si les paramètres ne sont pas des entiers
 * @author Votre Nom
 * @version 1.0.0
 * @since 1.0.0
 */
function addition(int $a, int $b) : int {
    return $a + $b;
}

/**
 * Classe Calculator pour effectuer des calculs mathématiques.
 *
 * Cette classe fournit des méthodes pour effectuer des opérations
 * mathématiques de base comme l'addition, la soustraction, etc.
 *
 * @package Calculator
 * @author Votre Nom
 * @version 1.0.0
 */
class Calculator
{
    /**
     * @var float $result Résultat du dernier calcul
     */
    private float $result = 0;

    /**
     * Constructeur de la classe Calculator.
     *
     * @param float $initialValue Valeur initiale du calculateur
     */
    public function __construct(float $initialValue = 0)
    {
        $this->result = $initialValue;
    }
}
```

Plus d'informations sur [le guide phpDocumentor](https://docs.phpdoc.org/guide/getting-started/what-is-a-docblock.html#what-is-a-docblock)


## Génération automatique

La documentation est générée automatiquement via GitHub Actions lors des push sur la branche main qui modifient les fichiers PHP dans le dossier `site/`.

Le workflow `documentation.yml` :
- Utilise PHP 8.3 avec les extensions nécessaires
- Exécute phpDocumentor avec le fichier de configuration
- Met à disposition la documentation générée en artefact téléchargeable dans github


## Génération manuelle

Pour générer la documentation localement en ligne de commande :

```bash
# Depuis la racine du projet avec le fichier de configuration
php documentation/tools/phpDocumentor.phar run -c documentation/tools/phpdoc.xml
```

### Consultation

Après génération, démarrez un serveur php sur le port 8001 et mappez-le avec le dossier ```documentation/generated```

```bash
# Démarrer un serveur simple sur le port 8001
php -S localhost:8001 -t documentation/generated/
```

Ouvrez dans le navigateur le site executé sur le port 8001 du conteneur pour consulter la documentation générée.

