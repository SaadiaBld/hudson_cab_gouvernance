-- enrichir les metadonnes de la table MART_DRIVER_MONTHLY avec des commentaires et des tags de gouvernance

USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- 1. La table : ce qu'elle contient, d'où elle vient, à quel rythme elle change
COMMENT ON TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY IS
  'Activité mensuelle de chaque chauffeur : services, heures, courses, recette.';

-- 2. Chaque colonne : sa signification
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.activity_month IS 'Mois de l''activité, au format AAAA-MM-01.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.driver_id IS 'Identifiant du chauffeur, clé de la table.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.driver_name IS 'Nom du chauffeur, tel qu''il doit être écrit partout.';

COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.depot IS 'Nom du dépôt où le chauffeur est affecté.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.nb_shifts IS 'Nombre de services effectués par le chauffeur dans le mois.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.hours_worked IS 'Nombre d''heures travaillées par le chauffeur dans le mois.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.trips_count IS 'Nombre de courses effectuées par le chauffeur dans le mois.';
COMMENT ON COLUMN NYC_TAXI.MARTS.MART_DRIVER_MONTHLY.revenue_usd IS 'Recette totale générée par le chauffeur dans le mois.';

-- 3. Les tags : la sensibilité et la durée de conservation se posent sur la table (les colonnes en héritent)
ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY SET TAG
  NYC_TAXI.GOUVERNANCE.SENSIBILITE        = 'interne',
  NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat';

ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN driver_id SET TAG
  NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';
ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY MODIFY COLUMN driver_name SET TAG
  NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';