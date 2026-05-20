<?php
abstract class AbstractRepository {
    protected PDO $pdo;
    protected string $table;
    protected string $primaryKey;
    protected array $allowedOrderColumns = [];

    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }

    public function findAll(array $where = [], string $orderBy = 'id', string $orderDir = 'ASC', ?int $limit = null): array {
        $orderDir = strtoupper($orderDir) === 'DESC' ? 'DESC' : 'ASC';
        if (!in_array($orderBy, $this->allowedOrderColumns, true)) {
            $orderBy = $this->primaryKey;
        }

        $sql = "SELECT * FROM {$this->table}";
        $params = [];

        if (!empty($where)) {
            $conditions = [];
            foreach ($where as $col => $val) {
                $conditions[] = "`$col` = :$col";
                $params[$col] = $val;
            }
            $sql .= " WHERE " . implode(' AND ', $conditions);
        }

        $sql .= " ORDER BY `$orderBy` $orderDir";
        if ($limit !== null) {
            $sql .= " LIMIT :limit";
        }

        $stmt = $this->pdo->prepare($sql);
        foreach ($params as $key => $val) {
            $stmt->bindValue(":$key", $val);
        }
        if ($limit !== null) {
            $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        }

        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function findById(int $id): ?array {
        $stmt = $this->pdo->prepare("SELECT * FROM {$this->table} WHERE {$this->primaryKey} = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function insert(array $data): int {
        $columns = array_map(fn($k) => "`$k`", array_keys($data));
        $placeholders = array_map(fn($k) => ":$k", array_keys($data));

        $sql = "INSERT INTO {$this->table} (" . implode(', ', $columns) . ") VALUES (" . implode(', ', $placeholders) . ")";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);

        return (int)$this->pdo->lastInsertId();
    }

    public function update(int $id, array $data): bool {
        $sets = array_map(fn($k) => "`$k` = :$k", array_keys($data));
        $data['id'] = $id;

        $sql = "UPDATE {$this->table} SET " . implode(', ', $sets) . " WHERE {$this->primaryKey} = :id";
        return $this->pdo->prepare($sql)->execute($data);
    }

    public function delete(int $id): bool {
        $stmt = $this->pdo->prepare("DELETE FROM {$this->table} WHERE {$this->primaryKey} = :id");
        return $stmt->execute(['id' => $id]);
    }
}
