DROP DATABASE IF EXISTS online_beauty_salon_variant5;
CREATE DATABASE online_beauty_salon_variant5
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE online_beauty_salon_variant5;

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (birth_date <= CURDATE() - INTERVAL 14 YEAR)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE masters (
    master_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    specialization ENUM('парикмахер', 'косметолог', 'маникюр', 'массажист', 'стилист') NOT NULL,
    phone VARCHAR(20) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 5.00 CHECK (rating BETWEEN 0 AND 5),
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    duration_minutes INT NOT NULL CHECK (duration_minutes BETWEEN 15 AND 240),
    requires_consultation BOOLEAN DEFAULT FALSE,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE consultations (
    consultation_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    master_id INT NOT NULL,
    consultation_date DATETIME NOT NULL,
    status ENUM('запланирована', 'проведена', 'отменена') DEFAULT 'запланирована',
    notes TEXT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (master_id) REFERENCES masters(master_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_consultation_slot (master_id, consultation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    master_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    status ENUM('запланировано', 'в_процессе', 'завершено', 'отменено') DEFAULT 'запланировано',
    total_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE RESTRICT,
    FOREIGN KEY (master_id) REFERENCES masters(master_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_master_slot (master_id, appointment_datetime),
    CHECK (appointment_datetime >= NOW())
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointment_services (
    appointment_service_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    price_at_booking DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_appointment_service (appointment_id, service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    stock_quantity DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    min_stock_level DECIMAL(10,2) DEFAULT 0,
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE service_products (
    service_product_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity_required DECIMAL(10,2) NOT NULL CHECK (quantity_required > 0),
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_service_product (service_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE additional_services (
    additional_service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointment_additional_services (
    appointment_additional_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    additional_service_id INT NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    FOREIGN KEY (additional_service_id) REFERENCES additional_services(additional_service_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_appointment_additional (appointment_id, additional_service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_appointments_datetime ON appointments(appointment_datetime);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_master ON appointments(master_id);
CREATE INDEX idx_services_consultation ON services(requires_consultation);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_appointment_services ON appointment_services(appointment_id, service_id);

INSERT INTO clients (last_name, first_name, patronymic, phone, email, birth_date) VALUES
('Иванова', 'Анна', 'Сергеевна', '+79161112233', 'anna.ivanova@mail.ru', '1995-03-15'),
('Петров', 'Дмитрий', 'Александрович', '+79162223344', 'dmitry.petrov@mail.ru', '1988-07-22'),
('Сидорова', 'Елена', 'Владимировна', '+79163334455', 'elena.sidorova@mail.ru', '2001-11-08'),
('Козлов', 'Максим', 'Игоревич', '+79164445566', 'maxim.kozlov@mail.ru', '1992-01-30'),
('Морозова', 'Ольга', 'Дмитриевна', '+79165556677', 'olga.morozova@mail.ru', '1999-05-12');

INSERT INTO masters (last_name, first_name, specialization, phone, rating) VALUES
('Соколова', 'Мария', 'парикмахер', '+79261112233', 4.9),
('Волков', 'Артём', 'косметолог', '+79262223344', 4.7),
('Лебедева', 'Екатерина', 'маникюр', '+79263334455', 5.0),
('Новиков', 'Павел', 'стилист', '+79264445566', 4.8);

INSERT INTO services (service_name, price, duration_minutes, requires_consultation, description) VALUES
('Стрижка женская', 2500.00, 60, FALSE, 'Классическая стрижка с укладкой'),
('Окрашивание волос', 4500.00, 120, TRUE, 'Полное окрашивание профессиональными красителями'),
('Уход за лицом', 3500.00, 45, TRUE, 'Комплексный уход с масками и пилингом'),
('Маникюр классический', 1800.00, 40, FALSE, 'Обрезной или аппаратный маникюр'),
('Укладка вечерняя', 2000.00, 30, FALSE, 'Создание праздничной причёски'),
('Ламинирование ресниц', 2200.00, 90, TRUE, 'Процедура укрепления и окрашивания ресниц');

INSERT INTO consultations (client_id, master_id, consultation_date, status, notes) VALUES
(1, 2, '2026-05-20 15:00:00', 'проведена', 'Обсуждён план окрашивания'),
(3, 3, '2026-05-22 11:00:00', 'запланирована', 'Консультация по форме ногтей');

INSERT INTO appointments (client_id, master_id, appointment_datetime, status, total_price) VALUES
(1, 1, '2026-05-25 10:00:00', 'запланировано', 4500.00),
(2, 2, '2026-05-25 14:00:00', 'запланировано', 3500.00),
(3, 3, '2026-05-26 09:00:00', 'запланировано', 1800.00),
(4, 1, '2026-05-27 16:00:00', 'запланировано', 2500.00),
(1, 3, '2026-05-28 11:00:00', 'запланировано', 3800.00);

INSERT INTO appointment_services (appointment_id, service_id, quantity, price_at_booking) VALUES
(1, 1, 1, 2500.00), (1, 5, 1, 2000.00),
(2, 3, 1, 3500.00),
(3, 4, 1, 1800.00),
(4, 1, 1, 2500.00),
(5, 4, 1, 1800.00), (5, 6, 1, 2200.00);

INSERT INTO products (product_name, unit, stock_quantity, min_stock_level, price_per_unit) VALUES
('Краска для волос', 'упаковка', 25.00, 10.00, 450.00),
('Шампунь профессиональный', 'литр', 15.00, 5.00, 800.00),
('Маска для лица', 'штука', 30.00, 10.00, 250.00),
('Лак для ногтей', 'штука', 40.00, 15.00, 350.00),
('Средство для ламинирования', 'набор', 12.00, 5.00, 1200.00),
('Гель для укладки', 'штука', 20.00, 8.00, 400.00);

INSERT INTO service_products (service_id, product_id, quantity_required) VALUES
(2, 1, 2.00), (2, 2, 0.10),
(3, 3, 1.00),
(4, 4, 0.50),
(5, 6, 0.30),
(6, 5, 1.00), (6, 2, 0.05);

INSERT INTO additional_services (service_name, price, description) VALUES
('Массаж головы', 500.00, 'Расслабляющий массаж 10 минут'),
('Парафинотерапия рук', 700.00, 'Увлажнение и питание кожи рук'),
('Укладка брашинг', 800.00, 'Объёмная укладка феном');

SELECT
    s1.service_name AS service_1,
    s2.service_name AS service_2,
    COUNT(*) AS booking_count
FROM appointment_services as1
JOIN appointment_services as2
    ON as1.appointment_id = as2.appointment_id
    AND as1.service_id < as2.service_id
JOIN services s1 ON as1.service_id = s1.service_id
JOIN services s2 ON as2.service_id = s2.service_id
GROUP BY as1.service_id, as2.service_id
ORDER BY booking_count DESC
LIMIT 10;
