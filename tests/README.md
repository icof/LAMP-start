# Tests unitaires

Ce dossier contient tous les tests unitaires du projet LAMP-start utilisant PHPUnit.

## Qu'est-ce que PHPUnit ?

**PHPUnit** est le framework de tests unitaires de référence pour PHP. Il permet de tester automatiquement votre code pour s'assurer qu'il fonctionne correctement et de détecter les régressions lors des modifications.

### Avantages des tests unitaires

- **Fiabilité** : Détection automatique des bugs et régressions
- **Refactoring sécurisé** : Modifier le code en toute confiance
- **Documentation vivante** : Les tests documentent le comportement attendu
- **Intégration continue** : Validation automatique via GitHub Actions

## Installation et configuration

### 1. Installer les dépendances

```bash
composer install
```

Cette commande installe PHPUnit et toutes les dépendances nécessaires définies dans `composer.json` à la racine du dépot.

### 2. Configuration automatique

Le projet génère automatiquement la configuration PHPUnit si aucun fichier `phpunit.xml` n'existe. La configuration par défaut :

- **Dossier source** : `site/`
- **Dossier tests** : `tests/`
- **Couverture de code** : Activée avec rapport HTML
- **Format de sortie** : Testdox (lisible)

## Exécution des tests

### Commandes de base

```bash
# Exécuter tous les tests avec format lisible
vendor/bin/phpunit --testdox tests/

# Exécuter tous les tests (format standard)
vendor/bin/phpunit tests/

# Exécuter un test spécifique
vendor/bin/phpunit --testdox tests/CalculatorTest.php

# Exécuter avec couverture de code
vendor/bin/phpunit --coverage-html coverage/ tests/
```

### Options utiles

```bash
# Mode debug (plus de détails)
vendor/bin/phpunit --debug tests/

# Arrêter au premier échec
vendor/bin/phpunit --stop-on-failure tests/

# Filtrer par méthode de test
vendor/bin/phpunit --filter testMethodName tests/

# Exécuter seulement les tests marqués avec un groupe
vendor/bin/phpunit --group unit tests/

# Afficher les informations de configuration
vendor/bin/phpunit --configuration tests/
```

## Écriture de tests

### Structure d'un test

```php
<?php

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * Test basique avec assertion
     */
    public function testBasicAssertion()
    {
        $this->assertEquals(4, 2 + 2);
        $this->assertTrue(true);
        $this->assertFalse(false);
    }

    /**
     * Test avec setup et teardown
     */
    protected function setUp(): void
    {
        // Préparation avant chaque test
        $this->calculator = new Calculator();
    }

    protected function tearDown(): void
    {
        // Nettoyage après chaque test
        $this->calculator = null;
    }

    /**
     * Test d'une méthode de classe
     */
    public function testCalculatorAddition()
    {
        $result = $this->calculator->add(2, 3);
        $this->assertEquals(5, $result);
    }
}
```

### Conventions de nommage

- **Fichiers** : `NomClasseTest.php` (ex: `CalculatorTest.php`)
- **Classes** : `NomClasseTest` extends `TestCase`
- **Méthodes** : `testDescriptionDuComportement()` ou `test_description_du_comportement()`

### Types d'assertions courantes

```php
// Égalité
$this->assertEquals($expected, $actual);
$this->assertSame($expected, $actual); // Identité stricte

// Booléens
$this->assertTrue($condition);
$this->assertFalse($condition);

// Null
$this->assertNull($value);
$this->assertNotNull($value);

// Arrays
$this->assertArrayHasKey('key', $array);
$this->assertContains($needle, $haystack);

// Exceptions
$this->expectException(InvalidArgumentException::class);
$this->expectExceptionMessage('Message d\'erreur');

// Types
$this->assertIsInt($value);
$this->assertIsString($value);
$this->assertInstanceOf(Calculator::class, $object);
```

### Annotations et attributs utiles

```php
/**
 * @group unit
 * @covers Calculator::add
 */
public function testAddition()
{
    // Test code
}

/**
 * @dataProvider additionDataProvider
 */
public function testAdditionWithDataProvider($a, $b, $expected)
{
    $result = $this->calculator->add($a, $b);
    $this->assertEquals($expected, $result);
}

public function additionDataProvider()
{
    return [
        [1, 2, 3],
        [0, 0, 0],
        [-1, 1, 0],
        [10, 5, 15],
    ];
}
```

## Organisation des tests

### Structure recommandée

```
tests/
├── README.md
├── Unit/              # Tests unitaires purs
│   ├── CalculatorTest.php
│   └── Models/
├── Integration/       # Tests d'intégration
│   └── DatabaseTest.php
├── Feature/          # Tests fonctionnels
│   └── ApiTest.php
└── Helpers/          # Classes d'aide pour les tests
    └── TestCase.php
```

### Catégories de tests

1. **Tests unitaires** : Testent une classe ou méthode isolée
2. **Tests d'intégration** : Testent l'interaction entre composants
3. **Tests fonctionnels** : Testent des scénarios complets utilisateur

## Tests avec base de données

### Configuration test database

```php
class DatabaseTestCase extends TestCase
{
    protected $pdo;

    protected function setUp(): void
    {
        // Connexion à une base de test
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->exec('CREATE TABLE users (id INT, name TEXT)');
    }

    protected function tearDown(): void
    {
        $this->pdo = null;
    }
}
```

### Fixtures et données de test

```php
protected function createTestUser()
{
    return [
        'id' => 1,
        'name' => 'Test User',
        'email' => 'test@example.com'
    ];
}
```

## Couverture de code

### Génération du rapport

```bash
# Générer un rapport HTML de couverture
vendor/bin/phpunit --coverage-html coverage/ tests/

# Rapport de couverture en mode texte
vendor/bin/phpunit --coverage-text tests/

# Rapport de couverture XML (pour CI)
vendor/bin/phpunit --coverage-xml coverage/xml tests/
```

### Annotations de couverture

```php
/**
 * @covers Calculator::add
 * @covers Calculator::subtract
 */
class CalculatorTest extends TestCase
{
    // Tests...
}
```

## Intégration continue

Les tests sont automatiquement exécutés via GitHub Actions dans le workflow `tests.yml` :

- **Déclenchement** : Push/PR modifiant PHP, composer.json ou composer.lock
- **Environnement** : PHP 8.3 avec extensions nécessaires
- **Rapport** : Couverture de code disponible en artefact

### Configuration du workflow

Le workflow génère automatiquement :
- Configuration PHPUnit adaptée au projet
- Exécution des tests avec détection intelligente
- Rapport de couverture téléchargeable

## Bonnes pratiques

### Tests efficaces

1. **Un test = un comportement** : Chaque test vérifie un seul aspect
2. **Noms explicites** : `testShouldReturnErrorWhenDividingByZero()`
3. **Arrange, Act, Assert** : Structure claire du test
4. **Tests indépendants** : Aucun test ne dépend d'un autre
5. **Données représentatives** : Cas normaux et cas limites

### Maintenance

```php
// ✅ Bon : Test clair et précis
public function testShouldCalculateDiscountCorrectly()
{
    // Arrange
    $price = 100;
    $discountRate = 0.1;
    
    // Act
    $finalPrice = $this->calculator->applyDiscount($price, $discountRate);
    
    // Assert
    $this->assertEquals(90, $finalPrice);
}

// ❌ Éviter : Test trop générique
public function testCalculator()
{
    $this->assertTrue($this->calculator->doSomething());
}
```

## Ressources utiles

- [Documentation officielle PHPUnit](https://phpunit.de/documentation.html)
- [Guide PHPUnit sur Grafikart](https://grafikart.fr/tutoriels/phpunit-test-unitaire-793)
- [Best practices pour les tests PHP](https://phpunit.de/best-practices.html)

## Dépannage problèmes courants

- **Consulter l'aide et lister les options disponibles** : ``` vendor/bin/phpunit --help ```
- Effectuer des **tests en mode debug** : ``` vendor/bin/phpunit --debug tests/ ```

### Messages d'erreur fréquents

- **"Class not found"** : Vérifier l'autoloader
```bash
# Classe non trouvée
composer dump-autoload
```
- **"No tests found"** : Vérifier les conventions de nommage
- **"Fatal error: Memory exhausted"** : Augmenter la limite mémoire PHP
```bash
# Erreur de mémoire
php -d memory_limit=512M vendor/bin/phpunit tests/
```



