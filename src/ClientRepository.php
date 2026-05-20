<?php
class ClientRepository extends AbstractRepository {
    public function __construct(PDO $pdo) {
        parent::__construct($pdo);
        $this->table = 'clients';
        $this->primaryKey = 'client_id';
        $this->allowedOrderColumns = ['client_id', 'last_name', 'first_name', 'birth_date', 'created_at'];
    }

    public function findByPhone(string $phone): ?array {
        $stmt = $this->pdo->prepare("SELECT * FROM {$this->table} WHERE phone = :phone");
        $stmt->execute(['phone' => $phone]);
        return $stmt->fetch() ?: null;
    }

    public function findByEmail(string $email): ?array {
        $stmt = $this->pdo->prepare("SELECT * FROM {$this->table} WHERE email = :email");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch() ?: null;
    }
}
