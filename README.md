# Gouvernance

## Points de vigilance réglementaire

- **R1 — Conservation de cinq ans : à justifier.** Le RGPD impose une durée justifiée par les finalités, mais ne fixe pas ici une règle générale de cinq ans. Il faut vérifier les obligations et délais applicables aux chauffeurs employés à New York, et justifier la durée pour chaque catégorie de données et chaque copie, y compris les services liés par `driver_id`. Sources : RGPD, articles 5 §1 e et 17 ; CNIL, référentiel RH, dont le champ vise le droit du travail français. À valider par le DPO et le conseil juridique.

- **R2 — Time Travel : préciser la portée.** Le contrat limite la restauration par Time Travel après un jour. La documentation Snowflake indique ensuite une période Fail-safe de sept jours pour les tables permanentes, réservée à une éventuelle récupération par Snowflake, et non à une restauration ordinaire par les rôles du compte. Ce n’est donc pas nécessairement un écart à la règle R2 telle qu’elle est écrite ; c’est une limite importante si l’on promettait un effacement définitif dès J+1. Sources : documentation Snowflake Time Travel et Fail-safe.

- **Accès : nécessité à démontrer.** La matrice par rôles, colonnes et dépôts va dans le sens de la minimisation et de la sécurité. Il faut néanmoins vérifier que chaque champ, notamment les heures, revenus et données détaillées de services, est nécessaire pour chaque rôle, et tester les politiques sur les données dérivées comme `driver_name`. Sources : RGPD, articles 5 §1 c, 25 et 32.

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