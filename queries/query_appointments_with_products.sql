USE online_beauty_salon_variant5;

SELECT
    a.appointment_id,
    c.last_name AS client_name,
    s.service_name,
    p.product_name,
    sp.quantity_required AS needed_for_service,
    p.stock_quantity AS available_in_stock,
    CASE
        WHEN p.stock_quantity >= sp.quantity_required THEN 'OK'
        ELSE 'NOT_ENOUGH'
    END AS stock_status
FROM appointments a
JOIN clients c ON a.client_id = c.client_id
JOIN appointment_services aps ON a.appointment_id = aps.appointment_id
JOIN services s ON aps.service_id = s.service_id
JOIN service_products sp ON s.service_id = sp.service_id
JOIN products p ON sp.product_id = p.product_id
WHERE a.status = 'запланировано'
ORDER BY a.appointment_datetime, p.product_name;
