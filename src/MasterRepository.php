<?php
class MasterRepository extends AbstractRepository {
    public function __construct(PDO $pdo) {
        parent::__construct($pdo);
        $this->table = 'masters';
        $this->primaryKey = 'master_id';
        $this->allowedOrderColumns = ['master_id', 'last_name', 'specialization', 'rating'];
    }

    public function getActiveMasters(): array {
        return $this->findAll(['is_active' => 1], 'rating', 'DESC');
    }
}
