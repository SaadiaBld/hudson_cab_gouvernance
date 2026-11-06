-- Nombre de services qui ne correspondent a aucun chauffeur connu.
-- Cette regle est bloquante au-dela de 50 anomalies.
SELECT COUNT(*) AS nb_anomalies
FROM NYC_TAXI.RAW.DRIVER_SHIFTS s
WHERE NOT EXISTS (
    SELECT 1
    FROM NYC_TAXI.RAW.DRIVERS d
    WHERE d.driver_id = s.driver_id
);