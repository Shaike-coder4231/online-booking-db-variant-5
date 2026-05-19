USE online_beauty_salon_variant5;

SELECT
    m.last_name,
    m.first_name,
    m.specialization,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    SUM(a.total_price) AS total_revenue,
    AVG(a.total_price) AS avg_check,
    COUNT(DISTINCT a.client_id) AS unique_clients
FROM masters m
LEFT JOIN appointments a ON m.master_id = a.master_id AND a.status != 'отменено'
GROUP BY m.master_id
ORDER BY total_revenue DESC;
