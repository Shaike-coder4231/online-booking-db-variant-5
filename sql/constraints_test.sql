USE online_beauty_salon_variant5;

INSERT INTO appointments (client_id, master_id, appointment_datetime, status, total_price)
VALUES (1, 1, '2026-05-25 10:00:00', 'запланировано', 1000.00);

DELETE FROM masters WHERE master_id = 1;

INSERT INTO clients (last_name, first_name, phone, email, birth_date)
VALUES ('Тестов', 'Ребёнок', '+79990001122', 'child@test.ru', '2020-01-01');

SELECT
    s.service_name,
    p.product_name,
    sp.quantity_required AS required,
    p.stock_quantity AS available,
    (sp.quantity_required - p.stock_quantity) AS shortage
FROM services s
JOIN service_products sp ON s.service_id = sp.service_id
JOIN products p ON sp.product_id = p.product_id
WHERE sp.quantity_required > p.stock_quantity;

SELECT
    a.appointment_id,
    c.last_name, c.first_name,
    s.service_name,
    a.appointment_datetime
FROM appointments a
JOIN clients c ON a.client_id = c.client_id
JOIN appointment_services aps ON a.appointment_id = aps.appointment_id
JOIN services s ON aps.service_id = s.service_id
WHERE s.requires_consultation = TRUE
AND NOT EXISTS (
    SELECT 1 FROM consultations co
    WHERE co.client_id = c.client_id
    AND co.status = 'проведена'
    AND co.consultation_date < a.appointment_datetime
);

INSERT INTO clients (last_name, first_name, phone, email, birth_date)
VALUES ('Дубль', 'Тест', '+79161112233', 'anna.ivanova@mail.ru', '1990-01-01');

INSERT INTO masters (last_name, first_name, specialization, phone, rating)
VALUES ('Фейк', 'Мастер', 'парикмахер', '+79991112233', 6.5);

INSERT INTO services (service_name, price, duration_minutes)
VALUES ('Бесплатная услуга', -100.00, 30);

INSERT INTO service_products (service_id, product_id, quantity_required)
VALUES (1, 1, 1.00);

INSERT INTO clients (last_name, first_name, phone, email, birth_date)
VALUES ('Удалить', 'Тест', '+79998887766', 'delete@test.ru', '1995-01-01');
SET @test_client = LAST_INSERT_ID();
INSERT INTO consultations (client_id, master_id, consultation_date)
VALUES (@test_client, 1, '2026-06-01 10:00:00');

DELETE FROM clients WHERE client_id = @test_client;

SELECT * FROM consultations WHERE client_id = @test_client;
