-- Politiques de masquage des colonnes personnelles de MARTS.
-- À exécuter avec ACCOUNTADMIN pour les privilèges globaux, puis GOUVERNANCE
-- pour créer les politiques et les attacher.

USE SECONDARY ROLES NONE;
USE ROLE ACCOUNTADMIN;
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE GOUVERNANCE;

USE SECONDARY ROLES NONE;
USE ROLE GOUVERNANCE;
USE WAREHOUSE NYC_TAXI_WH;

-- Le pipeline et la paie voient les valeurs complètes. Les responsables voient
-- nom/prénom/téléphone pour leurs lignes (le filtrage des lignes est séparé).
-- Les identifiants internes restent visibles des rôles métier. Tout autre accès
-- aux colonnes personnelles est masqué, y compris les rôles administrateurs.
CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_TEXTE
  AS (val VARCHAR) RETURNS VARCHAR -> val;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_TEXTE SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('TRANSFORMER', 'RH_PAIE') THEN val
    WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN(
           'NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE'
         ) = 'identifiant_interne'
         AND CURRENT_ROLE() IN (
           'ANALYSTE', 'RESP_DEPOT_QUEENS', 'RESP_DEPOT_BRONX'
         )
      THEN val
    WHEN CURRENT_ROLE() IN ('RESP_DEPOT_QUEENS', 'RESP_DEPOT_BRONX')
         AND SYSTEM$GET_TAG_ON_CURRENT_COLUMN(
               'NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE'
             ) IN ('nom', 'telephone')
      THEN val
    ELSE '***'
  END;

-- Pour l'analyste, seule l'année de naissance reste visible. Les rôles non
-- autorisés reçoivent NULL; hire_date/end_date utilisent aussi cette politique.
CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_DATE
  AS (val DATE) RETURNS DATE -> val;

ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_DATE SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('TRANSFORMER', 'RH_PAIE') THEN val
    WHEN CURRENT_ROLE() = 'ANALYSTE'
         AND SYSTEM$GET_TAG_ON_CURRENT_COLUMN(
               'NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE'
             ) = 'date_naissance'
      THEN DATE_FROM_PARTS(YEAR(val), 1, 1)
    ELSE NULL
  END;

-- Attacher la politique VARCHAR au tag : elle couvre les colonnes texte
-- taguées (noms, email, téléphone, licence, driver_name, driver_id).
EXECUTE IMMEDIATE $$
BEGIN
  ALTER TAG NYC_TAXI.GOUVERNANCE.DONNEE_PERSONNELLE
    SET MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_TEXTE,
        MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_DATE;
  RETURN 'Politiques texte et DATE attachées au tag.';
EXCEPTION
  WHEN STATEMENT_ERROR THEN
    RETURN 'Attachement non effectué; vérifier les politiques déjà attachées : ' || SQLERRM;
END;
$$;

-- hire_date et end_date n'ont pas de valeur dans DONNEE_PERSONNELLE; elles sont
-- néanmoins masquées pour les rôles métier, conformément au cahier de tests.
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER
  MODIFY COLUMN hire_date SET MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_DATE;
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER
  MODIFY COLUMN end_date SET MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_PERSONNE_DATE;

-- Contrôler les politiques effectivement attachées aux colonnes des deux marts.
SELECT policy_name, policy_kind, ref_entity_name, ref_column_name, tag_name
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_NAME => 'NYC_TAXI.MARTS.DIM_DRIVER', REF_ENTITY_DOMAIN => 'TABLE'));

SELECT policy_name, policy_kind, ref_entity_name, ref_column_name, tag_name
FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_NAME => 'NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', REF_ENTITY_DOMAIN => 'TABLE'));