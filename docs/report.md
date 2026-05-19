# Отчёт по практической работе

## Вариант 5: Онлайн-запись в салон красоты

**Выполнил:** Баженов Илья
**Группа:** 454
**Дата:** 19 мая 2026 г.

---

## 1. Описание предметной области

Система онлайн-записи в салон красоты с возможностью выбора мастера и дополнительных услуг. Некоторые услуги требуют обязательной предварительной консультации. Добавлена таблица продуктов, используемых мастером (расходные материалы). При создании записи должен проверяться остаток продуктов на складе.

## 2. Основные сущности

### Клиенты (clients)
- client_id (PK)
- last_name
- first_name
- patronymic
- phone (UNIQUE)
- email (UNIQUE)
- birth_date
- created_at

### Мастера (masters)
- master_id (PK)
- last_name
- first_name
- specialization (ENUM)
- phone
- rating (CHECK 0-5)
- is_active

### Услуги (services)
- service_id (PK)
- service_name (UNIQUE)
- price (CHECK > 0)
- duration_minutes (CHECK 15-240)
- requires_consultation (BOOLEAN)
- description

### Записи (appointments)
- appointment_id (PK)
- client_id (FK)
- master_id (FK)
- appointment_datetime
- status (ENUM)
- total_price
- created_at
- UNIQUE (master_id, appointment_datetime)

### Услуги в записях (appointment_services)
- appointment_service_id (PK)
- appointment_id (FK)
- service_id (FK)
- quantity
- price_at_booking
- UNIQUE (appointment_id, service_id)

### Продукты (products)
- product_id (PK)
- product_name (UNIQUE)
- unit
- stock_quantity (CHECK >= 0)
- min_stock_level
- price_per_unit

### Нормы расхода (service_products)
- service_product_id (PK)
- service_id (FK)
- product_id (FK)
- quantity_required
- UNIQUE (service_id, product_id)

### Консультации (consultations)
- consultation_id (PK)
- client_id (FK)
- master_id (FK)
- consultation_date
- status
- notes
- UNIQUE (master_id, consultation_date)

### Дополнительные услуги (additional_services)
- additional_service_id (PK)
- service_name
- price
- description

## 3. Нормализация

База данных приведена к 3NF (третьей нормальной форме):

1NF: Все атрибуты атомарны, нет повторяющихся групп

2NF: Все неключевые атрибуты зависят от полного первичного ключа

3NF: Отсутствуют транзитивные зависимости. Например, цена услуги хранится в таблице services, а не в appointment_services

## 4. Ограничения целостности

- PRIMARY KEY для всех таблиц
- FOREIGN KEY с ON DELETE CASCADE/RESTRICT
- UNIQUE для уникальных полей
- CHECK для проверки диапазонов значений
- NOT NULL для обязательных полей

## 5. Индексы

Созданы индексы для оптимизации запросов:
- idx_appointments_datetime
- idx_appointments_client
- idx_appointments_master
- idx_services_consultation
- idx_products_stock
- idx_appointment_services

## 6. Примеры запросов

### 6.1. Услуги, которые чаще всего записываются вместе
(см. queries/query_frequent_services.sql)

### 6.2. Проверка остатков продуктов
(см. queries/query_appointments_with_products.sql)

### 6.3. Аналитика загрузки мастеров
(см. queries/query_masters_load.sql)

## 7. Тестирование ограничений

Проверены следующие ограничения:
1. Уникальность временного слота мастера
2. Запрет удаления мастера с активными записями
3. Минимальный возраст клиента (14 лет)
4. Проверка наличия продуктов на складе
5. Обязательная консультация для некоторых услуг
6. Уникальность email и телефона
7. Диапазон рейтинга мастера (0-5)
8. Положительная цена услуги
9. Уникальность пары услуга-продукт
10. Каскадное удаление консультаций

## 8. Выводы

В ходе выполнения работы была спроектирована и реализована база данных для салона красоты. Реализованы все требования варианта, включая проверку остатков продуктов и обязательные консультации. База данных нормализована до 3NF, созданы необходимые индексы и ограничения целостности.

## Приложения

- ER-диаграмма: diagrams/er_diagram.png
- SQL схема: sql/schema.sql
- Тесты ограничений: sql/constraints_test.sql
