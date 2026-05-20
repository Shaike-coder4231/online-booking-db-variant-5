<?php
class ServiceRepository extends AbstractRepository {
    public function __construct(PDO $pdo) {
        parent::__construct($pdo);
        $this->table = 'services';
        $this->primaryKey = 'service_id';
        $this->allowedOrderColumns = ['service_id', 'service_name', 'price', 'duration_minutes'];
    }

    public function getServicesRequiringConsultation(): array {
        return $this->findAll(['requires_consultation' => 1], 'service_name');
    }
}
