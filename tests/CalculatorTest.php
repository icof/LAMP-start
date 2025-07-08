<?php

use PHPUnit\Framework\TestCase;

/**
 * Tests unitaires pour la classe Calculator
 *
 * Cette classe de test vérifie le bon fonctionnement de toutes les méthodes
 * de la classe Calculator, y compris la gestion des erreurs et de l'historique.
 */
class CalculatorTest extends TestCase
{
    /**
     * Instance de Calculator pour les tests
     *
     * @var Calculator
     */
    private Calculator $calculator;

    /**
     * Configuration avant chaque test
     *
     * Cette méthode est appelée avant chaque test pour créer une nouvelle
     * instance de Calculator avec un état propre.
     */
    protected function setUp(): void
    {
        // Charger la classe Calculator
        require_once __DIR__ . '/../site/classes/Calculator.php';
        
        // Créer une nouvelle instance pour chaque test
        $this->calculator = new Calculator();
    }

    /**
     * Test de l'addition simple
     */
    public function testAddition(): void
    {
        // Assert (vérification)
        $this->assertEquals(5, $this->calculator->add(3, 2));
        $this->assertEquals(-3, $this->calculator->add(-5, 2));
        $this->assertEquals(3, $this->calculator->add(-5, 2)); // test qui doit échouer

        $this->assertIsFloat($this->calculator->add(3, 2));
    }

    /**
     * Test de l'addition avec des nombres décimaux
     */
    public function testAdditionWithDecimals(): void
    {
        $result = $this->calculator->add(2.5, 3.7);
        $this->assertEquals(6.2, $result, '', 0.01); // delta pour les comparaisons flottantes
    }

    /**
     * Test de l'addition avec des nombres négatifs
     */
    public function testAdditionWithNegativeNumbers(): void
    {
        $result = $this->calculator->add(-5, 3);
        $this->assertEquals(-2, $result);
    }

    /**
     * Test de la soustraction
     */
    public function testSubtraction(): void
    {
        $result = $this->calculator->subtract(10, 4);
        $this->assertEquals(6, $result);
    }

    /**
     * Test de la multiplication
     */
    public function testMultiplication(): void
    {
        $result = $this->calculator->multiply(4, 5);
        $this->assertEquals(20, $result);
    }

    /**
     * Test de la multiplication par zéro
     */
    public function testMultiplicationByZero(): void
    {
        $result = $this->calculator->multiply(5, 0);
        $this->assertEquals(0, $result);
    }

    /**
     * Test de la division normale
     */
    public function testDivision(): void
    {
        $result = $this->calculator->divide(12, 3);
        $this->assertEquals(4, $result);
    }

    /**
     * Test de la division avec un résultat décimal
     */
    public function testDivisionWithDecimalResult(): void
    {
        $result = $this->calculator->divide(10, 4);
        $this->assertEquals(2.5, $result);
    }

    /**
     * Test de la division par zéro (doit lever une exception)
     */
    public function testDivisionByZeroThrowsException(): void
    {
        // On s'attend à ce qu'une exception soit levée
        $this->expectException(DivisionByZeroError::class);
        $this->expectExceptionMessage("Division par zéro impossible");

        // Cette ligne doit lever l'exception
        $this->calculator->divide(10, 0);
    }

    /**
     * Test de l'historique des calculs
     */
    public function testHistory(): void
    {
        // Effectuer quelques calculs
        $this->calculator->add(2, 3);
        $this->calculator->multiply(4, 5);

        // Vérifier l'historique
        $history = $this->calculator->getHistory();
        
        $this->assertCount(2, $history);
        $this->assertStringContainsString('2 + 3 = 5', $history[0]);
        $this->assertStringContainsString('4 × 5 = 20', $history[1]);
    }

    /**
     * Test de la remise à zéro de l'historique
     */
    public function testClearHistory(): void
    {
        // Effectuer un calcul
        $this->calculator->add(1, 1);
        
        // Vérifier qu'il y a un élément dans l'historique
        $this->assertCount(1, $this->calculator->getHistory());

        // Vider l'historique
        $this->calculator->clearHistory();

        // Vérifier que l'historique est vide
        $this->assertCount(0, $this->calculator->getHistory());
        $this->assertEmpty($this->calculator->getHistory());
    }

    /**
     * Test de l'historique avec l'heure
     */
    public function testHistoryContainsTimestamp(): void
    {
        $this->calculator->add(1, 2);
        $history = $this->calculator->getHistory();
        
        // Vérifier que l'entrée contient un format d'heure (HH:MM:SS)
        $this->assertMatchesRegularExpression('/\d{2}:\d{2}:\d{2}/', $history[0]);
    }

    /**
     * Test avec des données multiples (Data Provider)
     */
    public function testMultipleAdditions(): void
    {
        $testCases = [
            [1, 1, 2],
            [0, 5, 5],
            [-3, 7, 4],
            [2.5, 2.5, 5.0]
        ];

        foreach ($testCases as [$a, $b, $expected]) {
            $result = $this->calculator->add($a, $b);
            $this->assertEquals($expected, $result, "Test failed for $a + $b");
        }
    }

    /**
     * Test de performance (vérifier que les calculs sont rapides)
     */
    public function testPerformance(): void
    {
        $startTime = microtime(true);
        
        // Effectuer 1000 calculs
        for ($i = 0; $i < 1000; $i++) {
            $this->calculator->add($i, $i + 1);
        }
        
        $endTime = microtime(true);
        $executionTime = $endTime - $startTime;
        
        // Vérifier que l'exécution prend moins d'une seconde
        $this->assertLessThan(1.0, $executionTime, "Les calculs sont trop lents");
    }
}
