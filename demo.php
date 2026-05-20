<?php
require_once 'src/RepositoryException.php';
require_once 'src/Database.php';
require_once 'src/AbstractRepository.php';
require_once 'src/ClientRepository.php';
require_once 'src/MasterRepository.php';
require_once 'src/ServiceRepository.php';
require_once 'src/AppointmentRepository.php';

header('Content-Type: text/html; charset=utf-8');
echo "<pre>";

try {
    $pdo = Database::getInstance()->getConnection();
    echo "✅ Подключение к БД успешно\n\n";

    $clientRepo = new ClientRepository($pdo);
    $masterRepo = new MasterRepository($pdo);
    $serviceRepo = new ServiceRepository($pdo);
    $appointmentRepo = new AppointmentRepository($pdo);

    // 1. Выбор всех клиентов
    echo "📋 Все клиенты:\n";
    print_r($clientRepo->findAll([], 'last_name', 'ASC', 3));

    // 2. Поиск клиента по телефону
    echo "\n📞 Поиск клиента по телефону +79161112233:\n";
    print_r($clientRepo->findByPhone('+79161112233'));

    // 3. Активные мастера по рейтингу
    echo "\n⭐ Топ мастеров:\n";
    print_r($masterRepo->getActiveMasters());

    // 4. Услуги, требующие консультации
    echo "\n🩺 Услуги с обязательной консультацией:\n";
    print_r($serviceRepo->getServicesRequiringConsultation());

    // 5. Записи на определённую дату
    echo "\n📅 Записи на 2026-05-25:\n";
    print_r($appointmentRepo->getAppointmentsByDate('2026-05-25'));

    // 6. Создание новой записи (с транзакцией)
    echo "\n➕ Создание новой записи:\n";
    $newId = $appointmentRepo->createAppointment(1, 1, 5, '2026-06-01 10:00:00');
    echo "Создана запись ID: $newId\n";

    // 7. Изменение статуса
    echo "\n🔄 Изменение статуса записи $newId на 'в_процессе':\n";
    $appointmentRepo->updateStatus($newId, 'в_процессе');
    print_r($appointmentRepo->findById($newId));

    // 8. Удаление записи
    echo "\n️ Удаление записи $newId:\n";
    $appointmentRepo->delete($newId);
    echo "Удалено: " . ($appointmentRepo->findById($newId) === null ? 'Да' : 'Нет') . "\n";

    // 9. Демонстрация защиты от инъекций (безопасный orderBy)
    echo "\n️ Тест безопасности (orderBy игнорирует недопустимые значения):\n";
    print_r($clientRepo->findAll([], 'DROP TABLE clients; --', 'ASC', 2));

} catch (RepositoryException $e) {
    echo "\n❌ Ошибка репозитория: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "\n❌ Критическая ошибка: " . $e->getMessage() . "\n";
}

echo "</pre>";
