USE online_beauty_salon_variant5;

SELECT
    s1.service_name AS service_1,
    s2.service_name AS service_2,
    COUNT(*) AS booking_count,
    SUM(aps1.price_at_booking + aps2.price_at_booking) AS total_revenue
FROM appointment_services aps1
JOIN appointment_services aps2
    ON aps1.appointment_id = aps2.appointment_id
    AND aps1.service_id < aps2.service_id
JOIN services s1 ON aps1.service_id = s1.service_id
JOIN services s2 ON aps2.service_id = s2.service_id
GROUP BY aps1.service_id, aps2.service_id
ORDER BY booking_count DESC, total_revenue DESC
LIMIT 10;
