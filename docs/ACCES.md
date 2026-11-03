# Les accès — carte des droits et cahier de tests

## Partie 1 — Carte des droits

Les droits ci-dessous sont ceux accordés par `snowflake/00_installation.sql` et `snowflake/gouvernance/01_gouvernance.sql`. Les accès métier et les politiques seront complétés aux étapes suivantes.

### Qui possède quoi

| Objet | Propriétaire |
|---|---|
| Tables de `RAW` et de `MARTS` créées par le pipeline | `TRANSFORMER` |
| Schéma `NYC_TAXI.GOUVERNANCE` | `GOUVERNANCE` |
| Tags de `NYC_TAXI.GOUVERNANCE` | `GOUVERNANCE` |
| Politiques de masquage | À créer par `GOUVERNANCE` |
| Politique d'accès par ligne | À créer par `GOUVERNANCE` |
| Table `ACCES_DEPOT` | À créer |
| Table `QUALITE_RESULTATS` | `GOUVERNANCE` |
| Vue `V_CATALOGUE` | À déterminer à sa création |

### Qui fait quoi, avec quel droit

| Action | Rôle qui la fait | Privilège nécessaire | Accordé par |
|---|---|---|---|
| Utiliser `NYC_TAXI_WH` | `TRANSFORMER` | `USAGE`, `OPERATE` sur le warehouse | `ACCOUNTADMIN` |
| Utiliser `NYC_TAXI_WH` | `GOUVERNANCE` | `USAGE` sur le warehouse | `ACCOUNTADMIN` |
| Utiliser `NYC_TAXI` | `TRANSFORMER`, `GOUVERNANCE` | `USAGE` sur la base | `ACCOUNTADMIN` |
| Utiliser `RAW` pour créer les tables source | `TRANSFORMER` | `USAGE`, `CREATE TABLE`, `CREATE STAGE`, `CREATE FILE FORMAT` sur le schéma | `ACCOUNTADMIN` |
| Utiliser `STAGING` pour créer les vues de typage | `TRANSFORMER` | `USAGE`, `CREATE TABLE`, `CREATE VIEW` sur le schéma | `ACCOUNTADMIN` |
| Utiliser `MARTS` pour créer les tables et tâches | `TRANSFORMER` | `USAGE`, `CREATE TABLE`, `CREATE VIEW`, `CREATE TASK` sur le schéma | `ACCOUNTADMIN` |
| Exécuter les tâches planifiées | `TRANSFORMER` | `EXECUTE TASK` sur le compte | `ACCOUNTADMIN` |
| Utiliser `RAW` pour repérer les tables à gouverner | `GOUVERNANCE` | `USAGE` sur le schéma, sans `SELECT` | `ACCOUNTADMIN` |
| Utiliser `MARTS` pour repérer les tables à gouverner | `GOUVERNANCE` | `USAGE` sur le schéma, sans `SELECT` | `ACCOUNTADMIN` |
| Créer les objets de gouvernance | `GOUVERNANCE` | Propriété du schéma `NYC_TAXI.GOUVERNANCE` | `ACCOUNTADMIN` |
| Attacher les politiques de masquage | `GOUVERNANCE` | `APPLY MASKING POLICY` sur le compte | `ACCOUNTADMIN` |
| Attacher les politiques d'accès par ligne | `GOUVERNANCE` | `APPLY ROW ACCESS POLICY` sur le compte | `ACCOUNTADMIN` |
| Poser `SENSIBILITE` sur une table | `TRANSFORMER` | `USAGE` sur le schéma de gouvernance et `APPLY` sur le tag | `GOUVERNANCE` |
| Poser `DONNEE_PERSONNELLE` sur une colonne | `TRANSFORMER` | `USAGE` sur le schéma de gouvernance et `APPLY` sur le tag | `GOUVERNANCE` |
| Poser `DUREE_CONSERVATION` sur une table | `TRANSFORMER` | `USAGE` sur le schéma de gouvernance et `APPLY` sur le tag | `GOUVERNANCE` |
| Écrire dans `QUALITE_RESULTATS` | `TRANSFORMER` | `INSERT` sur la table | `GOUVERNANCE` |
| Lire `QUALITE_RESULTATS` | `TRANSFORMER` | `SELECT` sur la table | `GOUVERNANCE` |
| Créer la vue du catalogue dans le schéma de gouvernance | `TRANSFORMER` | `CREATE VIEW` sur le schéma | `GOUVERNANCE` |
| Lire les tables RH de `RAW` et `MARTS` | `GOUVERNANCE` | Aucun `SELECT` accordé | — |

`GOUVERNANCE` et `TRANSFORMER` sont accordés à l'utilisateur courant par `ACCOUNTADMIN`. `TRANSFORMER` est également accordé à `SYSADMIN` dans le script d'installation. Le rôle `GOUVERNANCE` n'est pas rattaché à `SYSADMIN` ni à `TRANSFORMER`.

### Ce que cette carte permet à un rôle de défaire

`TRANSFORMER` peut poser ou retirer les tags sur ses propres tables. Le rôle peut donc modifier les métadonnées utilisées par les futures politiques fondées sur les tags ; les résultats devront être vérifiés après chaque changement de tag. `GOUVERNANCE` peut attacher des politiques à des tables qu'il ne possède pas grâce aux privilèges accordés sur le compte.

## Partie 2 — Cahier de tests

À compléter après la création et l'attachement des politiques. Décidez d'abord à quoi ressemble une valeur masquée pour chaque type de colonne (texte, date) et notez-le ici : ______. Écrivez les résultats attendus avant les politiques, puis les résultats obtenus après leur création.

### Lignes visibles

| N° | Rôle | Requête | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|---|
| 1 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 2 | `RESP_DEPOT_QUEENS` | la même | | | |
| 3 | `RESP_DEPOT_QUEENS` | `SELECT DISTINCT depot FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 4 | `RESP_DEPOT_BRONX` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY` | | | |
| 5 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | | | |
| 6 | `GOUVERNANCE` | la même | | | |
| 7 | `ACCOUNTADMIN` | la même | | | |
| 8 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS` | | | |
| 9 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS` | | | |
| 9 bis | `ACCOUNTADMIN` | `SELECT first_name, email FROM NYC_TAXI.RAW.DRIVERS LIMIT 3` | | | |

### Valeurs visibles

Pour le chauffeur `D0003`, indiquer la valeur lisible par chaque rôle, ou « colonne absente » / « ligne invisible ».

| Colonne | `RH_PAIE` | `RESP_DEPOT_QUEENS` | `RESP_DEPOT_BRONX` | `ANALYSTE` |
|---|---|---|---|---|
| nom et prénom | | | | |
| e-mail | | | | |
| téléphone | | | | |
| date de naissance | | | | |
| numéro de licence | | | | |
| `driver_name` dans `MART_DRIVER_MONTHLY` | | | | |

### Le pipeline fonctionne toujours

| N° | Vérification | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|
| 10 | Avec le rôle des outils, après avoir relancé les fichiers SQL : nombre de lignes de `DIM_DRIVER` | | | |
| 11 | Avec `RH_PAIE` : l'e-mail de `D0003` est toujours une vraie adresse | | | |
| 12 | Les politiques sont toujours attachées après la relance | | | |

Ajoutez des tests de cas limites au fur et à mesure de la création des politiques et des tâches planifiées.