# Gouvernance

## Points de vigilance réglementaire

- **R1 — Conservation de cinq ans : à justifier.** Le RGPD impose une durée justifiée par les finalités, mais ne fixe pas ici une règle générale de cinq ans. Il faut vérifier les obligations et délais applicables aux chauffeurs employés à New York, et justifier la durée pour chaque catégorie de données et chaque copie, y compris les services liés par `driver_id`. Sources : RGPD, articles 5 §1 e et 17 ; CNIL, référentiel RH, dont le champ vise le droit du travail français. À valider par le DPO et le conseil juridique.

- **R2 — Time Travel : préciser la portée.** Le contrat limite la restauration par Time Travel après un jour. La documentation Snowflake indique ensuite une période Fail-safe de sept jours pour les tables permanentes, réservée à une éventuelle récupération par Snowflake, et non à une restauration ordinaire par les rôles du compte. Ce n’est donc pas nécessairement un écart à la règle R2 telle qu’elle est écrite ; c’est une limite importante si l’on promettait un effacement définitif dès J+1. Sources : documentation Snowflake Time Travel et Fail-safe.

- **Accès : nécessité à démontrer.** La matrice par rôles, colonnes et dépôts va dans le sens de la minimisation et de la sécurité. Il faut néanmoins vérifier que chaque champ, notamment les heures, revenus et données détaillées de services, est nécessaire pour chaque rôle, et tester les politiques sur les données dérivées comme `driver_name`. Sources : RGPD, articles 5 §1 c, 25 et 32.

### Décision colonne par colonne pour l'analyste

Les rôles métier lisent les mêmes tables de `MARTS`. Les colonnes nécessaires à la paie ou aux responsables restent donc dans ces tables ; les valeurs que l'analyste ne doit pas voir en clair sont masquées selon le rôle. Aucune colonne de `MARTS` n'est supprimée dans cette décision.

| Table | Colonne | Décision pour l'analyste | Raison |
|---|---|---|---|
| `DIM_DRIVER` | `driver_id` | Conserver en clair | Identifiant interne explicitement autorisé par le contrat pour compter et joindre sans nommer. |
| `DIM_DRIVER` | `first_name` | Masquer (`***`) | Identifie directement le chauffeur ; prénom en clair réservé à la paie et au responsable de son dépôt. |
| `DIM_DRIVER` | `last_name` | Masquer (`***`) | Identifie directement le chauffeur ; nom en clair réservé à la paie et au responsable de son dépôt. |
| `DIM_DRIVER` | `email` | Masquer (`***`), ne pas supprimer | L'analyste n'en a pas besoin pour ses analyses. La colonne reste dans la table commune parce que la paie doit pouvoir lire l'adresse en clair. |
| `DIM_DRIVER` | `phone` | Masquer (`***`) | Coordonnée directement identifiante ; en clair uniquement pour la paie et le responsable du dépôt concerné. |
| `DIM_DRIVER` | `birth_date` | Masquer au jour et au mois ; conserver seulement l'année | Le contrat autorise l'année de naissance seulement. La valeur technique `YYYY-01-01` représente l'année, pas une date complète. |
| `DIM_DRIVER` | `tlc_license_number` | Masquer (`***`) | Numéro officiel directement identifiant ; sa valeur en clair est réservée à la paie. |
| `DIM_DRIVER` | `depot` | Conserver en clair | Nécessaire aux analyses par dépôt et à la politique d'accès par ligne ; la valeur visible reste limitée aux dépôts autorisés. |
| `DIM_DRIVER` | `hire_date` | Masquer (`NULL`) | La date exacte n'est pas nécessaire à l'analyste et peut contribuer à réidentifier une personne ; `tenure_years` fournit une mesure moins précise. |
| `DIM_DRIVER` | `end_date` | Masquer (`NULL`) | La date exacte de départ n'est pas nécessaire à l'analyste ; `is_active` et `tenure_years` couvrent les besoins agrégés retenus. |
| `DIM_DRIVER` | `is_active` | Conserver en clair | Indicateur opérationnel utile pour comparer chauffeurs actifs et inactifs, sans identité directe. |
| `DIM_DRIVER` | `tenure_years` | Conserver en clair | Mesure d'ancienneté utile à l'analyse RH sans exposer les dates exactes d'embauche et de départ. |
| `MART_DRIVER_MONTHLY` | `activity_month` | Conserver en clair | Nécessaire aux analyses d'évolution mensuelle. |
| `MART_DRIVER_MONTHLY` | `driver_id` | Conserver en clair | Identifiant interne autorisé par le contrat pour joindre et compter. |
| `MART_DRIVER_MONTHLY` | `driver_name` | Masquer (`***`) | Nom directement identifiant dérivé de `first_name` et `last_name` ; le masque doit couvrir cette copie dérivée aussi. |
| `MART_DRIVER_MONTHLY` | `depot` | Conserver en clair | Nécessaire aux analyses par dépôt et au filtrage des lignes. |
| `MART_DRIVER_MONTHLY` | `nb_shifts` | Conserver en clair | Mesure d'activité demandée pour l'analyse ; accessible seulement sur les lignes autorisées. |
| `MART_DRIVER_MONTHLY` | `hours_worked` | Conserver en clair | Mesure d'activité demandée pour l'analyse ; accessible seulement sur les lignes autorisées. |
| `MART_DRIVER_MONTHLY` | `trips_count` | Conserver en clair | Mesure d'activité demandée pour l'analyse ; accessible seulement sur les lignes autorisées. |
| `MART_DRIVER_MONTHLY` | `revenue_usd` | Conserver en clair | Mesure financière demandée pour l'analyse ; accessible seulement sur les lignes autorisées. |
| `DIM_DEPOT` | `depot` | Conserver en clair | Référentiel nécessaire pour identifier et regrouper les dépôts ; aucune donnée personnelle. |
| `DIM_DEPOT` | `quartier` | Conserver en clair | Information descriptive du dépôt, sans donnée personnelle. |
| `DIM_DEPOT` | `ouvert_en` | Conserver en clair | Année d'ouverture du dépôt, sans donnée personnelle. |
| `DIM_DEPOT` | `nb_places` | Conserver en clair | Capacité du dépôt, sans donnée personnelle. |

**Pourquoi garder l'e-mail masqué plutôt que supprimer la colonne ?** L'analyste n'a pas de besoin métier pour l'e-mail ; toutefois, supprimer la colonne de la table partagée empêcherait aussi `RH_PAIE` de la consulter, contrairement à la matrice. Si l'exigence devient que l'analyste ne puisse même pas voir la colonne, il faudra lui donner accès à une vue dédiée sans `email` et lui retirer le `SELECT` direct sur la table. Le masquage seul cache les valeurs, pas le nom ni l'existence de la colonne.

Toute suppression physique ultérieure devra être cohérente dans `snowflake/rh/00_tables_rh.sql` et dans les scripts qui construisent les tables ou leurs colonnes dérivées. Comme `CREATE TABLE IF NOT EXISTS` ne modifie pas une table existante, la colonne devra aussi être supprimée de la table déjà créée avec `ALTER TABLE ... DROP COLUMN`, en utilisant `TRANSFORMER`, propriétaire des tables de `MARTS`.

- **Qualité : les contrôles ne suffisent pas seuls.** Les tests SQL contribuent à l’exactitude, mais il faut aussi prévoir comment corriger une erreur et traiter une demande de rectification. Sources : RGPD, articles 5 §1 d, 16 et 24.

- **Stage : contrôle opérationnel à prouver.** `PURGE = TRUE` est utile, mais Snowflake précise que la purge peut échouer sans signaler d’erreur. Vérifier que le stage est vide après chargement ; ce contrôle ne supprime pas les copies dans les tables, leur historique ou les fichiers locaux. Sources : RGPD, articles 5 et 32 ; documentation Snowflake `COPY INTO`, option `PURGE`.

## Actions et validations

- Faire confirmer les rôles de Hudson Cab Europe et Hudson Cab Partners, ainsi que le contrat de sous-traitance Snowflake.
- Vérifier les règles de conservation applicables à New York et documenter la justification de R1.
- Vérifier la région du compte Snowflake et les éventuels accès ou transferts hors EEE ; la région seule ne suffit pas à conclure qu’un transfert est conforme ou non.
- Conserver les preuves des tests d’accès, de purge et des durées de rétention.

## Publication des données RH
Pour des soucis de confidentialité, les données ne sont pas publiées sur le repo GitHub.

## 