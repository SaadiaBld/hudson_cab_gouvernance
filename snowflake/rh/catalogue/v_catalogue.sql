-- Catalogue des colonnes des tables MARTS lues par les roles metier.
-- A executer avec TRANSFORMER, proprietaire de la vue.
USE SECONDARY ROLES NONE;
USE ROLE TRANSFORMER;
USE WAREHOUSE NYC_TAXI_WH;

CREATE OR REPLACE VIEW NYC_TAXI.GOUVERNANCE.V_CATALOGUE AS
WITH tags AS (
    SELECT object_database, object_schema, object_name, column_name, tag_name, tag_value
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DRIVER', 'table'))
    UNION ALL
    SELECT object_database, object_schema, object_name, column_name, tag_name, tag_value
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.MART_DRIVER_MONTHLY', 'table'))
    UNION ALL
    SELECT object_database, object_schema, object_name, column_name, tag_name, tag_value
    FROM TABLE(NYC_TAXI.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('NYC_TAXI.MARTS.DIM_DEPOT', 'table'))
)
SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.comment,
    LISTAGG(g.tag_name || '=' || g.tag_value, ', ')
        WITHIN GROUP (ORDER BY g.tag_name) AS liste_tags
FROM NYC_TAXI.INFORMATION_SCHEMA.COLUMNS c
LEFT JOIN tags g
    ON  c.table_catalog = g.object_database
    AND c.table_schema  = g.object_schema
    AND c.table_name    = g.object_name
    AND c.column_name   = g.column_name
WHERE c.table_schema = 'MARTS'
  AND c.table_name IN ('DIM_DRIVER', 'MART_DRIVER_MONTHLY', 'DIM_DEPOT')
GROUP BY
    c.table_name,
    c.column_name,
    c.data_type,
    c.comment
ORDER BY c.table_name, c.column_name;
GRANT SELECT ON VIEW NYC_TAXI.GOUVERNANCE.V_CATALOGUE TO ROLE ANALYSTE;

-- Verifier les trois tables et leurs colonnes avant de tester le role metier.
SELECT table_name, COUNT(*) AS nb_colonnes
FROM NYC_TAXI.GOUVERNANCE.V_CATALOGUE
GROUP BY table_name
ORDER BY table_name;

USE SECONDARY ROLES NONE;
USE ROLE ANALYSTE;
USE WAREHOUSE NYC_TAXI_WH;

SELECT table_name, COUNT(*) AS nb_colonnes
FROM NYC_TAXI.GOUVERNANCE.V_CATALOGUE
GROUP BY table_name
ORDER BY table_name;
