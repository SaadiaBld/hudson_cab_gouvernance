-- Enrichir les métadonnées de RAW.DRIVER_SHIFTS avec des commentaires et des tags de gouvernance.

USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- 1. La table : ce qu'elle contient, d'où elle vient, à quel rythme elle change
COMMENT ON TABLE NYC_TAXI.RAW.DRIVER_SHIFTS IS
  'Données brutes sur les postes de travail des chauffeurs de Hudson Cab Partners : 1 ligne = 1 service.';

-- 2. Chaque colonne : sa signification
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.depot IS 'Nom du dépôt où le chauffeur est affecté.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.driver_id IS 'Identifiant du chauffeur, clé de la table.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.hours_worked IS 'Nombre d''heures travaillées pendant le service.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.revenue_usd IS 'Revenu généré en dollars.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.shift_date IS 'Date du service.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.shift_id IS 'Identifiant du service, clé de la table.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.start_hour IS 'Heure de début du service.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS.trips_count IS 'Nombre de trajets effectués pendant le service.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS._source_file IS 'Nom du fichier source ayant fourni la ligne.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVER_SHIFTS._loaded_at IS 'Date et heure de chargement de la ligne.';

-- 3. Les tags : la sensibilité et la durée de conservation se posent sur la table (les colonnes en héritent)
ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE        = 'interne',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat';

ALTER TABLE NYC_TAXI.RAW.DRIVER_SHIFTS MODIFY COLUMN driver_id SET TAG
  NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';