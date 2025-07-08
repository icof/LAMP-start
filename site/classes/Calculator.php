<?php
/**
 * Classe Calculator - Exemple de documentation PHPDoc
 *
 * Cette classe fournit des méthodes basiques de calcul mathématique.
 * Elle sert d'exemple pour illustrer la documentation automatique avec phpDocumentor.
 *
 * @package ExempleLAMP
 * @author Équipe de développement
 * @version 1.0.0
 * @since 2025-07-08
 *
 * @example
 * ```php
 * $calc = new Calculator();
 * $result = $calc->add(5, 3); // Retourne 8
 * ```
 */
class Calculator
{
    /**
     * Historique des calculs effectués
     *
     * @var array<string> Liste des opérations réalisées
     */
    private array $history = [];

    /**
     * Additionne deux nombres
     *
     * Cette méthode effectue une addition simple entre deux nombres
     * et enregistre l'opération dans l'historique.
     *
     * @param float $a Premier nombre à additionner
     * @param float $b Deuxième nombre à additionner
     *
     * @return float Résultat de l'addition
     *
     * @throws InvalidArgumentException Si les paramètres ne sont pas numériques
     *
     * @example
     * ```php
     * $calc = new Calculator();
     * echo $calc->add(5, 3); // Affiche: 8
     * ```
     */
    public function add(float $a, float $b): float
    {
        $result = $a + $b;
        $this->addToHistory("$a + $b = $result");
        return $result;
    }

    /**
     * Soustrait le deuxième nombre du premier
     *
     * @param float $a Nombre duquel soustraire
     * @param float $b Nombre à soustraire
     *
     * @return float Résultat de la soustraction
     */
    public function subtract(float $a, float $b): float
    {
        $result = $a - $b;
        $this->addToHistory("$a - $b = $result");
        return $result;
    }

    /**
     * Multiplie deux nombres
     *
     * @param float $a Premier facteur
     * @param float $b Deuxième facteur
     *
     * @return float Produit de la multiplication
     */
    public function multiply(float $a, float $b): float
    {
        $result = $a * $b;
        $this->addToHistory("$a × $b = $result");
        return $result;
    }

    /**
     * Divise le premier nombre par le deuxième
     *
     * @param float $a Dividende (nombre à diviser)
     * @param float $b Diviseur (nombre par lequel diviser)
     *
     * @return float Résultat de la division
     *
     * @throws DivisionByZeroError Si le diviseur est zéro
     */
    public function divide(float $a, float $b): float
    {
        if ($b == 0) {
            throw new DivisionByZeroError("Division par zéro impossible");
        }
        
        $result = $a / $b;
        $this->addToHistory("$a ÷ $b = $result");
        return $result;
    }

    /**
     * Retourne l'historique des calculs
     *
     * @return array<string> Liste des opérations effectuées
     */
    public function getHistory(): array
    {
        return $this->history;
    }

    /**
     * Vide l'historique des calculs
     *
     * @return void
     */
    public function clearHistory(): void
    {
        $this->history = [];
    }

    /**
     * Ajoute une opération à l'historique
     *
     * Méthode privée utilisée pour enregistrer chaque calcul effectué.
     *
     * @param string $operation Description de l'opération effectuée
     *
     * @return void
     */
    private function addToHistory(string $operation): void
    {
        $this->history[] = date('H:i:s') . " - " . $operation;
    }
}
