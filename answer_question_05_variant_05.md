# Ответ на контрольный вопрос №5

**Выполнил:** Баженов Илья
**Группа:** 454
**Вариант:** 5

**Вопрос:** Напишите запрос для вывода услуг, которые чаще всего записываются вместе (сочетания).

---

## Развёрнутый ответ

Для решения задачи анализа часто совместно записываемых услуг в базе данных салона красоты используется таблица-связка `appointment_services`, которая реализует связь многие-ко-многим между записями (`appointments`) и услугами (`services`). Это позволяет одной записи содержать несколько услуг, что типично для сферы красоты (например, «Стрижка + Укладка» или «Маникюр + Парафинотерапия»).

### Структура задействованных таблиц:


```sql
CREATE TABLE services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    requires_consultation BOOLEAN DEFAULT FALSE
);

CREATE TABLE appointment_services (
    appointment_service_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1,
    price_at_booking DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    UNIQUE KEY unique_appointment_service (appointment_id, service_id)
);
