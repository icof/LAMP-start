<?php
/**
 * Page d'accueil du site LAMP
 * 
 * Cette page sert d'exemple pour tester la génération de documentation
 * avec phpDocumentor.
 * 
 * @author Votre équipe de développement
 * @version 1.0
 * @since 2025-07-08
 */

require_once 'classes/Calculator.php';
require_once 'classes/User.php';

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site LAMP - Exemple de documentation</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .demo-section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .success { color: green; font-weight: bold; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h1>🎯 Site LAMP - Exemple de documentation</h1>
    
    <div class="demo-section">
        <h2>📊 Test de la classe Calculator</h2>
        <?php
        $calc = new Calculator();
        $result = $calc->add(5, 3);
        echo "<p class='success'>5 + 3 = " . $result . "</p>";
        
        $result2 = $calc->multiply(4, 7);
        echo "<p class='success'>4 × 7 = " . $result2 . "</p>";
        ?>
    </div>
    
    <div class="demo-section">
        <h2>👤 Test de la classe User</h2>
        <?php
        $user = new User("Alice", "alice@example.com");
        echo "<p class='success'>Utilisateur créé : " . $user->getFullInfo() . "</p>";
        echo "<p class='info'>Email valide : " . ($user->isEmailValid() ? "Oui" : "Non") . "</p>";
        ?>
    </div>
    
    <div class="demo-section">
        <h2>📚 Génération de la documentation</h2>
        <p>Pour générer la documentation de ce code :</p>
        <pre><code>php documentation/tools/phpDocumentor.phar run -d ./site -t ./documentation</code></pre>
    </div>

</body>
</html>
