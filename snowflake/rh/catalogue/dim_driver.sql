-- enrichir les metadonnes de la table DIM_DRIVER avec des commentaires et des tags de gouvernance
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

-- 1. La table : ce qu'elle contient, d'où elle vient, à quel rythme elle change
COMMENT ON TABLE NYC_TAXI.MARTS.DIM_DRIVER IS
  'Référentiel des chauffeurs de Hudson Cab Partners : 1 ligne = 1 chauffeur. ';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.driver_id IS 'Identifiant du chauffeur, clé de la table.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.first_name IS 'Prénom du chauffeur, tel qu''il doit être écrit partout.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.last_name IS 'Nom du chauffeur, tel qu''il doit être écrit partout.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.email IS 'Adresse email du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.phone IS 'Numéro de téléphone du chauffeur.';   
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.birth_date IS 'Date de naissance du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.tlc_license_number IS 'Numéro de licence TLC du chauffeur.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.depot IS 'Nom du dépôt où le chauffeur est affecté.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.hire_date IS 'Date d''embauche du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.end_date IS 'Date de fin de contrat du chauffeur.';
COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.is_active IS 'Indicateur de l''état actif du chauffeur.';

COMMENT ON COLUMN NYC_TAXI.MARTS.DIM_DRIVER.tenure_years IS 'Durée d''ancienneté du chauffeur en années.';

-- 3. Les tags : la sensibilité et la durée de conservation se posent sur la table (les colonnes en héritent)
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER SET TAG
    NYC_TAXI.GOUVERNANCE.SENSIBILITE        = 'confidentiel',
    NYC_TAXI.GOUVERNANCE.DUREE_CONSERVATION = '5 ans après la fin du contrat';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN driver_id SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_interne';

ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN first_name SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom'; 
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN last_name SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'nom';
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN email SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'email';
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN phone SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'telephone';
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN birth_date SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'date_naissance';
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER MODIFY COLUMN tlc_license_number SET TAG
    NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE = 'identifiant_officiel';

-- 4. Vérifier
SELECT column_name, comment FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'MARTS' AND table_name = 'DIM_DRIVER' ORDER BY ordinal_position;

SELECT level, column_name, tag_name, tag_value
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DRIVER', 'table'));
