-- Enrichir les métadonnées de RAW.DRIVERS avec des commentaires et des tags de gouvernance.
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- 1. La table : ce qu'elle contient, d'où elle vient, à quel rythme elle change
COMMENT ON TABLE NYC_TAXI.RAW.DRIVERS IS
  'Données brutes sur les chauffeurs de Hudson Cab Partners : 1 ligne = 1 chauffeur. ';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.driver_id IS 'Identifiant du chauffeur, clé de la table.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.first_name IS 'Prénom du chauffeur, tel qu''il doit être écrit partout.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.last_name IS 'Nom du chauffeur, tel qu''il doit être écrit partout.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.email IS 'Adresse email du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.phone IS 'Numéro de téléphone du chauffeur.';   
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.birth_date IS 'Date de naissance du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.tlc_license_number IS 'Numéro de licence TLC du chauffeur.';

COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.depot IS 'Nom du dépôt où le chauffeur est affecté.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.hire_date IS 'Date d''embauche du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS.end_date IS 'Date de fin de contrat du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS._source_file IS 'Nom du fichier source contenant les données du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.RAW.DRIVERS._loaded_at IS 'Timestamp de chargement des données.';

-- 3. Les tags : la sensibilité et la durée de conservation se posent sur la table (les colonnes en héritent)
ALTER TABLE NYC_TAXI.RAW.DRIVERS SET TAG 
    NYC_TAXI.GOUVERNANCE.SENSIBILITE        = 'confidentiel',
    NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN driver_id SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN first_name SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom'; 
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN last_name SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN email SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'email';
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN phone SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'telephone';
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN birth_date SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'date_naissance';
ALTER TABLE NYC_TAXI.RAW.DRIVERS MODIFY COLUMN tlc_license_number SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_officiel';

-- 4. Vérifier
SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'RAW' AND table_name = 'DRIVERS' ORDER BY ordinal_position;

SELECT level, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.RAW.DRIVERS', 'table'));
