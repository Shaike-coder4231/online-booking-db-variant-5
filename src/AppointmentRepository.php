<?php
class AppointmentRepository extends AbstractRepository {
    public function __construct(PDO $pdo) {
        parent::__construct($pdo);
        $this->table = 'appointments';
        $this->primaryKey = 'appointment_id';
        $this->allowedOrderColumns = ['appointment_id', 'appointment_datetime', 'status', 'total_price'];
    }

    public function getAppointmentsByDate(string $date): array {
        $stmt = $this->pdo->prepare("
            SELECT * FROM {$this->table}
            WHERE DATE(appointment_datetime) = :date
            ORDER BY appointment_datetime ASC
        ");
        $stmt->execute(['date' => $date]);
        return $stmt->fetchAll();
    }

    public function getFreeSlots(int $masterId, string $date): array {
        $stmt = $this->pdo->prepare("
            SELECT t.slot_time FROM (
                SELECT '09:00:00' as slot_time UNION SELECT '10:00:00' UNION SELECT '11:00:00'
                UNION SELECT '12:00:00' UNION SELECT '13:00:00' UNION SELECT '14:00:00'
                UNION SELECT '15:00:00' UNION SELECT '16:00:00' UNION SELECT '17:00:00' UNION SELECT '18:00:00'
            ) t
            LEFT JOIN {$this->table} a ON TIME(a.appointment_datetime) = t.slot_time
                AND DATE(a.appointment_datetime) = :date AND a.master_id = :masterId
            WHERE a.appointment_id IS NULL
        ");
        $stmt->execute(['date' => $date, 'masterId' => $masterId]);
        return $stmt->fetchAll();
    }

    public function createAppointment(int $clientId, int $masterId, int $serviceId, string $datetime, string $status = 'запланировано'): int {
        $this->pdo->beginTransaction();
        try {
            // Проверка занятости слота
            $stmt = $this->pdo->prepare("SELECT COUNT(*) as cnt FROM {$this->table} WHERE master_id = :masterId AND appointment_datetime = :datetime");
            $stmt->execute(['masterId' => $masterId, 'datetime' => $datetime]);
            if ($stmt->fetch()['cnt'] > 0) {
                throw new RepositoryException("Время уже занято другим клиентом");
            }

            // Получение стоимости услуги
            $stmt = $this->pdo->prepare("SELECT price FROM services WHERE service_id = :id");
            $stmt->execute(['id' => $serviceId]);
            $service = $stmt->fetch();
            if (!$service) throw new RepositoryException("Услуга не найдена");

            // Создание записи
            $appointmentId = $this->insert([
                'client_id' => $clientId,
                'master_id' => $masterId,
                'appointment_datetime' => $datetime,
                'status' => $status,
                'total_price' => $service['price']
            ]);

            // Привязка услуги к записи
            $stmt = $this->pdo->prepare("INSERT INTO appointment_services (appointment_id, service_id, quantity, price_at_booking) VALUES (:appId, :servId, 1, :price)");
            $stmt->execute(['appId' => $appointmentId, 'servId' => $serviceId, 'price' => $service['price']]);

            $this->pdo->commit();
            return $appointmentId;
        } catch (Exception $e) {
            $this->pdo->rollBack();
            throw new RepositoryException($e->getMessage());
        }
    }

    public function updateStatus(int $id, string $status): bool {
        $allowed = ['запланировано', 'в_процессе', 'завершено', 'отменено'];
        if (!in_array($status, $allowed, true)) {
            throw new RepositoryException("Недопустимый статус записи");
        }
        return $this->update($id, ['status' => $status]);
    }
}
