--limiter les acces à certianes lignes pour les resp de depot
USE SECONDARY ROLES NONE;
USE ROLE GOUVERNANCE;
USE WAREHOUSE NYC_TAXI_WH;

-- on cree une table de correspondance qui associe un nom de role a un depot
CREATE TABLE IF NOT EXISTS NYC_TAXI.GOUVERNANCE.ACCES_DEPOT(
    role_name VARCHAR NOT NULL,
    depot    VARCHAR NOT NULL     -- un dépôt, ou * pour tous
);

DELETE FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT;
INSERT INTO NYC_TAXI.GOUVERNANCE.ACCES_DEPOT VALUES
    ('RESP_DEPOT_QUEENS', 'Queens'),
    ('RESP_DEPOT_BRONX', 'Bronx'),
    ('ANALYSTE', '*'),
    ('RH_PAIE', '*'),
    ('TRANSFORMER', '*');

CREATE ROW ACCESS POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.POLICY_DEPOT
  AS (depot_ligne VARCHAR) RETURNS BOOLEAN -> FALSE;     -- corps provisoire (rejouable)

ALTER ROW ACCESS POLICY NYC_TAXI.GOUVERNANCE.POLICY_DEPOT SET BODY ->
  EXISTS (
    SELECT 1
    FROM NYC_TAXI.GOUVERNANCE.ACCES_DEPOT a
    WHERE a.role_name = CURRENT_ROLE()          -- le rôle actif, pas les rôles secondaires
      AND a.depot IN (depot_ligne, '*')
  );
-- Le DROP ALL rend le bloc rejouable : l'attachement est une métadonnée de la table,
-- indépendante des lignes rechargées dans ACCES_DEPOT. Ces tables ne portent que cette règle.
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER DROP ALL ROW ACCESS POLICIES;
ALTER TABLE NYC_TAXI.MARTS.DIM_DRIVER ADD ROW ACCESS POLICY NYC_TAXI.GOUVERNANCE.POLICY_DEPOT ON (depot);
ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY DROP ALL ROW ACCESS POLICIES;
ALTER TABLE NYC_TAXI.MARTS.MART_DRIVER_MONTHLY ADD ROW ACCESS POLICY NYC_TAXI.GOUVERNANCE.POLICY_DEPOT ON (depot);
