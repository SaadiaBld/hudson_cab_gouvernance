-- Nombre de chauffeurs en poste sans telephone renseigne.
-- Le seuil d'avertissement est calcule a chaque mesure : 5 % des chauffeurs en poste.
SELECT COUNT(*) AS nb_anomalies
FROM NYC_TAXI.RAW.DRIVERS
WHERE end_date IS NULL
  AND NULLIF(TRIM(phone), '') IS NULL;