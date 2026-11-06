-- Taches quotidiennes du pipeline RH.
-- Executer ce fichier avec TRANSFORMER, proprietaire des tables et de la vue de catalogue.
-- Pour modifier un graphe deja actif, suspendre d'abord T_PURGE.
USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE TRANSFORMER;

USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- Racine : purge RAW chaque jour a 05:00, heure de Paris.
-- Les services sont supprimes avant les chauffeurs pour respecter leur rattachement.
CREATE OR REPLACE TASK NYC_TAXI.MARTS.T_PURGE
  WAREHOUSE = NYC_TAXI_WH
  SCHEDULE = 'USING CRON 0 5 * * * Europe/Paris'
AS
EXECUTE IMMEDIATE $$
BEGIN
  DELETE FROM NYC_TAXI.RAW.DRIVER_SHIFTS
  WHERE driver_id IN (
    SELECT driver_id
    FROM NYC_TAXI.RAW.DRIVERS
    WHERE end_date IS NOT NULL
      AND end_date <= DATEADD(year, -5, CURRENT_DATE())
  );

  DELETE FROM NYC_TAXI.RAW.DRIVERS
  WHERE end_date IS NOT NULL
    AND end_date <= DATEADD(year, -5, CURRENT_DATE());

  RETURN 'RAW purge terminee';
END;
$$;

-- Mesure les regles, enregistre chaque resultat, puis bloque le graphe
-- si service_rattache depasse son seuil de 50 anomalies.
CREATE OR REPLACE TASK NYC_TAXI.MARTS.T_QUALITE
  WAREHOUSE = NYC_TAXI_WH
  AFTER NYC_TAXI.MARTS.T_PURGE
AS
EXECUTE IMMEDIATE $$
DECLARE
  nb_licence NUMBER;
  nb_telephone NUMBER;
  nb_chauffeurs_en_poste NUMBER;
  seuil_telephone NUMBER(18,2);
  nb_services_orphelins NUMBER;
  seuil_licence NUMBER DEFAULT 0;
  seuil_services NUMBER DEFAULT 50;
  mesure_le TIMESTAMP_NTZ;
  echec_service_rattache EXCEPTION (-20001, 'service_rattache depasse le seuil bloquant de 50');
BEGIN
  mesure_le := CURRENT_TIMESTAMP()::TIMESTAMP_NTZ;

  SELECT COUNT(*) - COUNT(DISTINCT tlc_license_number)
    INTO :nb_licence
  FROM NYC_TAXI.RAW.DRIVERS;

    SELECT COALESCE(COUNT_IF(end_date IS NULL), 0),
      COALESCE(COUNT_IF(end_date IS NULL AND NULLIF(TRIM(phone), '') IS NULL), 0)
    INTO :nb_chauffeurs_en_poste, :nb_telephone
  FROM NYC_TAXI.RAW.DRIVERS;
  seuil_telephone := nb_chauffeurs_en_poste * 0.05;

  SELECT COUNT(*)
    INTO :nb_services_orphelins
  FROM NYC_TAXI.RAW.DRIVER_SHIFTS s
  WHERE NOT EXISTS (
    SELECT 1
    FROM NYC_TAXI.RAW.DRIVERS d
    WHERE d.driver_id = s.driver_id
  );

  INSERT INTO NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS
    (regle, mesure_le, nb_anomalies, seuil, statut)
  VALUES
    ('licence_unique', :mesure_le, :nb_licence, :seuil_licence,
     IFF(:nb_licence > :seuil_licence, 'ALERTE', 'OK'));

  INSERT INTO NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS
    (regle, mesure_le, nb_anomalies, seuil, statut)
  VALUES
    ('telephone_renseigne', :mesure_le, :nb_telephone, :seuil_telephone,
     IFF(:nb_telephone > :seuil_telephone, 'ALERTE', 'OK'));

  INSERT INTO NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS
    (regle, mesure_le, nb_anomalies, seuil, statut)
  VALUES
    ('service_rattache', :mesure_le, :nb_services_orphelins, :seuil_services,
     IFF(:nb_services_orphelins > :seuil_services, 'ALERTE', 'OK'));

  IF (nb_services_orphelins > seuil_services) THEN
    RAISE echec_service_rattache;
  END IF;

  RETURN 'Mesures de qualite enregistrees';
END;
$$;

-- Reconstruction des marts uniquement si T_QUALITE a reussi.
CREATE OR REPLACE TASK NYC_TAXI.MARTS.T_TABLES
  WAREHOUSE = NYC_TAXI_WH
  AFTER NYC_TAXI.MARTS.T_QUALITE
AS
EXECUTE IMMEDIATE $$
BEGIN
  INSERT OVERWRITE INTO NYC_TAXI.MARTS.DIM_DEPOT (depot, quartier, ouvert_en, nb_places) VALUES
    ('Bronx', 'Hunts Point', 2009, 140),
    ('Brooklyn', 'East New York', 2011, 120),
    ('Queens', 'Long Island City', 2008, 180);

  INSERT OVERWRITE INTO NYC_TAXI.MARTS.DIM_DRIVER
  SELECT
    driver_id,
    first_name,
    last_name,
    email,
    phone,
    birth_date,
    tlc_license_number,
    depot,
    hire_date,
    end_date,
    end_date IS NULL AS is_active,
    ROUND(DATEDIFF(day, hire_date, COALESCE(end_date, CURRENT_DATE())) / 365.25, 1) AS tenure_years
  FROM NYC_TAXI.STAGING.STG_RH__DRIVERS;

  INSERT OVERWRITE INTO NYC_TAXI.MARTS.MART_DRIVER_MONTHLY
  SELECT
    DATE_TRUNC('month', s.shift_date)::date AS activity_month,
    s.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    s.depot,
    COUNT(*) AS nb_shifts,
    ROUND(SUM(s.hours_worked), 1) AS hours_worked,
    SUM(s.trips_count) AS trips_count,
    ROUND(SUM(s.revenue_usd), 2) AS revenue_usd
  FROM NYC_TAXI.STAGING.STG_RH__DRIVER_SHIFTS s
  LEFT JOIN NYC_TAXI.MARTS.DIM_DRIVER d ON d.driver_id = s.driver_id
  GROUP BY 1, 2, 3, 4;

  RETURN 'Tables MARTS reconstruites';
END;
$$;

-- Les taches sont creees suspendues. Activer le graphe et lancer la racine
-- seulement apres verification des trois definitions ci-dessus.
SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('NYC_TAXI.MARTS.T_PURGE');
EXECUTE TASK NYC_TAXI.MARTS.T_PURGE;

-- Suivre les executions, sans afficher les executions planifiees futures.
SELECT name, state, error_message, completed_time
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name IN ('T_PURGE', 'T_QUALITE', 'T_TABLES')
  AND state <> 'SCHEDULED'
ORDER BY completed_time DESC
LIMIT 20;

SELECT regle, mesure_le, nb_anomalies, seuil, statut
FROM NYC_TAXI.GOUVERNANCE.QUALITE_RESULTATS
ORDER BY mesure_le DESC, regle;

-- Pour prouver le blocage, modifier le seuil de service_rattache dans la declaration
-- de T_QUALITE pour qu'il soit inferieur au nombre d'anomalies, puis :
--   ALTER TASK NYC_TAXI.MARTS.T_PURGE SUSPEND;
--   CREATE OR REPLACE TASK ... (mettre a jour T_QUALITE)
--   SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('NYC_TAXI.MARTS.T_PURGE');
--   EXECUTE TASK NYC_TAXI.MARTS.T_PURGE;
-- Verifier T_QUALITE en FAILED et l'absence d'execution de T_TABLES, puis remettre 50.
