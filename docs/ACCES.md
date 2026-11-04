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

Ce cahier fixe les résultats attendus **avant** d'écrire et d'attacher les politiques. Les effectifs ci-dessous sont calculés à partir des CSV actuellement fournis, après la normalisation `INITCAP(TRIM(depot))` du staging. Si les fichiers changent, recalculer les effectifs avant les tests.

### Convention de masquage décidée

| Donnée | Affichage attendu |
|---|---|
| Chaîne personnelle masquée (nom, e-mail, téléphone ou licence) | `***` |
| `driver_id` | Visible pour tous les rôles métier, conformément au contrat |
| `birth_date` pour `RH_PAIE` | Date complète, par exemple `1981-12-07` |
| `birth_date` pour `ANALYSTE` | Année seulement, représentée par `YYYY-01-01` (ex. `1981-01-01`; janvier et le jour 1 sont des valeurs techniques) |
| `birth_date` pour un responsable de dépôt | `NULL` |
| `driver_name` dans `MART_DRIVER_MONTHLY` | Même règle que le nom : clair pour la paie et le responsable autorisé pour la ligne, `***` pour l'analyste |

La paie voit toutes les données personnelles en clair. Les responsables voient en clair prénom, nom et téléphone uniquement pour leur dépôt ; e-mail, date de naissance et licence sont masqués. L'analyste voit les identifiants internes, mais aucune donnée qui identifie directement un chauffeur ; seule l'année de naissance est conservée.

### Lignes visibles

| N° | Rôle | Requête | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|---|
| 1 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | 400 chauffeurs, tous dépôts | | |
| 2 | `RESP_DEPOT_QUEENS` | même requête sur `DIM_DRIVER` | 161 chauffeurs de Queens seulement | | |
| 3 | `RESP_DEPOT_QUEENS` | `SELECT DISTINCT depot FROM NYC_TAXI.MARTS.DIM_DRIVER` | une valeur : `Queens` | | |
| 4 | `RESP_DEPOT_BRONX` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | 122 chauffeurs du Bronx seulement | | |
| 5 | `RESP_DEPOT_BRONX` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY` | 290 lignes mensuelles du Bronx seulement | | |
| 6 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | 400 chauffeurs, tous dépôts | | |
| 7 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY` | 914 lignes mensuelles, tous dépôts | | |
| 8 | rôles métier | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DEPOT` | 3 dépôts pour chacun ; aucun filtre par dépôt | | |
| 9 | `GOUVERNANCE` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | requête refusée : aucun `SELECT` sur les données RH | | |
| 10 | `ACCOUNTADMIN` | `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | 0 ligne selon la matrice, même si le rôle peut atteindre la table | | |
| 11 | `RH_PAIE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVER_SHIFTS` | requête refusée : `RAW` n'est pas accessible aux rôles métier | | |
| 12 | `ANALYSTE` | `SELECT COUNT(*) FROM NYC_TAXI.RAW.DRIVERS` | requête refusée : l'analyste ne lit que `MARTS` | | |
| 13 | `ACCOUNTADMIN` | `SELECT first_name, email FROM NYC_TAXI.RAW.DRIVERS LIMIT 3` | 3 lignes ; colonnes personnelles masquées conformément au contrat | | |

Synthèse des effectifs attendus pour les données actuellement fournies :

| Rôle | `DIM_DRIVER` | `MART_DRIVER_MONTHLY` | `DIM_DEPOT` | Dépôts visibles dans les tables RH |
|---|---:|---:|---:|---|
| `RH_PAIE` | 400 | 914 | 3 | tous |
| `RESP_DEPOT_QUEENS` | 161 | 365 | 3 | Queens seulement |
| `RESP_DEPOT_BRONX` | 122 | 290 | 3 | Bronx seulement |
| `ANALYSTE` | 400 | 914 | 3 | tous |
| `TRANSFORMER` | 400 | 914 | 3 | tous |
| `GOUVERNANCE` | requête refusée | requête refusée | pas de `SELECT` métier | aucun accès aux données RH |
| `ACCOUNTADMIN` | 0 selon la matrice | 0 selon la matrice | hors périmètre RH | aucun |

Les 914 lignes mensuelles sont réparties en 365 à Queens, 290 au Bronx et 259 à Brooklyn. `DIM_DEPOT` est un référentiel non filtré : chacun des rôles métier qui le lit doit voir ses trois lignes.

### Valeurs visibles

Vérifier ces exemples de la source actuelle. Une ligne marquée « invisible » doit être absente du résultat, et non retournée avec des colonnes masquées.

| Chauffeur et rôle | Résultat attendu dans `DIM_DRIVER` |
|---|---|
| `D0003`, `RH_PAIE` | ligne visible : `Anthony Suarez`, `anthony.suarez3@mail.example`, `+1 (917) 555-2473`, `1981-12-07`, licence `5213863`, `driver_id = D0003` |
| `D0003`, `RESP_DEPOT_QUEENS` | ligne visible : prénom `Anthony`, nom `Suarez`, téléphone `+1 (917) 555-2473` ; e-mail et licence `***` ; naissance `NULL` ; `driver_id = D0003` |
| `D0003`, `RESP_DEPOT_BRONX` | ligne invisible : D0003 est rattaché à Queens |
| `D0003`, `ANALYSTE` | ligne visible : `driver_id = D0003` ; prénom, nom, e-mail, téléphone et licence `***` ; naissance `1981-01-01` (année seulement) |
| `D0001`, `RH_PAIE` | ligne visible : `Thomas Pierre`, `thomas.pierre1@post.example`, `+1 (917) 555-0161`, `1957-07-24`, licence `5841963`, `driver_id = D0001` |
| `D0001`, `RESP_DEPOT_BRONX` | ligne visible : prénom `Thomas`, nom `Pierre`, téléphone `+1 (917) 555-0161` ; e-mail et licence `***` ; naissance `NULL` ; `driver_id = D0001` |
| `D0001`, `RESP_DEPOT_QUEENS` | ligne invisible : D0001 est rattaché au Bronx |
| `D0001`, `ANALYSTE` | ligne visible : `driver_id = D0001` ; prénom, nom, e-mail, téléphone et licence `***` ; naissance `1957-01-01` (année seulement) |

Dans `MART_DRIVER_MONTHLY`, vérifier aussi les lignes de `D0003` (Queens) et `D0001` (Bronx) : la paie voit les deux noms, chaque responsable voit uniquement la ligne de son dépôt et l'analyste voit les deux lignes avec `driver_name = '***'`. Les mesures agrégées restent visibles à l'analyste.

### Le pipeline fonctionne toujours

| N° | Vérification | Attendu | Obtenu | Vert ? |
|---|---|---|---|---|
| 14 | Avec `TRANSFORMER`, après avoir relancé le chargement : `SELECT COUNT(*) FROM NYC_TAXI.MARTS.DIM_DRIVER` | 400 lignes ; tous dépôts | | |
| 15 | Avec `TRANSFORMER` : `SELECT COUNT(*) FROM NYC_TAXI.MARTS.MART_DRIVER_MONTHLY` | 914 lignes ; tous dépôts | | |
| 16 | Avec `RH_PAIE` : lire l'e-mail de `D0003` | adresse complète `anthony.suarez3@mail.example` | | |
| 17 | Après le rechargement, vérifier les politiques avec `INFORMATION_SCHEMA.POLICY_REFERENCES` | politique de ligne et masquages toujours attachés aux tables/colonnes attendues | | |

Les rôles de test doivent être activés un par un avec `USE SECONDARY ROLES NONE; USE ROLE <ROLE>;`. Ajoutez les tests de cas limites et inscrivez les résultats obtenus seulement après leur exécution.