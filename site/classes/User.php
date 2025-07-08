<?php
/**
 * Classe User - Exemple de gestion d'utilisateurs
 *
 * Cette classe illustre une implémentation simple d'un modèle utilisateur
 * avec validation d'email et méthodes de base. Elle sert d'exemple pour
 * la génération de documentation avec phpDocumentor.
 *
 * @package Site\Classes
 * @author Votre équipe de développement
 * @version 1.0
 * @since 2025-07-08
 * @example
 * ```php
 * $user = new User("Jean Dupont", "jean@example.com");
 * echo $user->getFullInfo();
 * ```
 */
class User
{
    /**
     * Nom complet de l'utilisateur
     *
     * @var string
     */
    private string $name;

    /**
     * Adresse email de l'utilisateur
     *
     * @var string
     */
    private string $email;

    /**
     * Date de création de l'utilisateur
     *
     * @var DateTime
     */
    private DateTime $createdAt;

    /**
     * Constructeur de la classe User
     *
     * Initialise un nouvel utilisateur avec son nom et son email.
     * La date de création est automatiquement définie à l'instant présent.
     *
     * @param string $name Nom complet de l'utilisateur
     * @param string $email Adresse email de l'utilisateur
     * @throws InvalidArgumentException Si le nom est vide ou l'email invalide
     */
    public function __construct(string $name, string $email)
    {
        if (empty(trim($name))) {
            throw new InvalidArgumentException("Le nom ne peut pas être vide");
        }

        if (!$this->validateEmail($email)) {
            throw new InvalidArgumentException("L'adresse email n'est pas valide");
        }

        $this->name = trim($name);
        $this->email = strtolower(trim($email));
        $this->createdAt = new DateTime();
    }

    /**
     * Récupère le nom de l'utilisateur
     *
     * @return string Le nom complet de l'utilisateur
     */
    public function getName(): string
    {
        return $this->name;
    }

    /**
     * Récupère l'email de l'utilisateur
     *
     * @return string L'adresse email de l'utilisateur
     */
    public function getEmail(): string
    {
        return $this->email;
    }

    /**
     * Récupère la date de création
     *
     * @return DateTime La date et heure de création de l'utilisateur
     */
    public function getCreatedAt(): DateTime
    {
        return $this->createdAt;
    }

    /**
     * Modifie le nom de l'utilisateur
     *
     * @param string $name Le nouveau nom de l'utilisateur
     * @throws InvalidArgumentException Si le nom est vide
     * @return void
     */
    public function setName(string $name): void
    {
        if (empty(trim($name))) {
            throw new InvalidArgumentException("Le nom ne peut pas être vide");
        }

        $this->name = trim($name);
    }

    /**
     * Modifie l'email de l'utilisateur
     *
     * @param string $email La nouvelle adresse email
     * @throws InvalidArgumentException Si l'email n'est pas valide
     * @return void
     */
    public function setEmail(string $email): void
    {
        if (!$this->validateEmail($email)) {
            throw new InvalidArgumentException("L'adresse email n'est pas valide");
        }

        $this->email = strtolower(trim($email));
    }

    /**
     * Valide le format d'une adresse email
     *
     * Utilise la fonction filter_var avec FILTER_VALIDATE_EMAIL
     * pour vérifier la validité syntaxique de l'email.
     *
     * @param string $email L'adresse email à valider
     * @return bool True si l'email est valide, false sinon
     */
    public function isEmailValid(): bool
    {
        return $this->validateEmail($this->email);
    }

    /**
     * Retourne les informations complètes de l'utilisateur
     *
     * Génère une chaîne contenant le nom, l'email et la date de création
     * formatée de manière lisible.
     *
     * @return string Les informations formatées de l'utilisateur
     */
    public function getFullInfo(): string
    {
        return sprintf(
            "%s (%s) - Créé le %s",
            $this->name,
            $this->email,
            $this->createdAt->format('d/m/Y à H:i')
        );
    }

    /**
     * Convertit l'utilisateur en tableau associatif
     *
     * Utile pour la sérialisation JSON ou l'export vers une base de données.
     *
     * @return array<string, mixed> Tableau associatif des propriétés
     */
    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s')
        ];
    }

    /**
     * Méthode privée de validation d'email
     *
     * @param string $email L'adresse email à valider
     * @return bool True si l'email est valide, false sinon
     */
    private function validateEmail(string $email): bool
    {
        return filter_var(trim($email), FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Représentation textuelle de l'utilisateur
     *
     * Méthode magique appelée lors de la conversion de l'objet en chaîne.
     *
     * @return string Le nom de l'utilisateur
     */
    public function __toString(): string
    {
        return $this->name;
    }
}
