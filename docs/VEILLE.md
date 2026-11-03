# Note de veille réglementaire — données du personnel de Hudson Cab Partners

Note de travail établie le 2 novembre 2026 à partir de `CONTEXTE_BRIEF.md`, des fichiers RH fictifs du kit et du `CONTRAT_GOUVERNANCE.md`. Les conclusions sur les rôles et les durées sont à confirmer par le conseil juridique/DPO avant tout traitement réel. Une veille doit être suivie dans le temps : les abonnements et la capture demandés ci-dessous restent à réaliser par le binôme.

## 1. Le droit applicable

Le traitement : les données de chauffeurs employés à New York, gérées depuis Paris par Hudson Cab Europe, à qui le groupe a confié leur gestion.

| Question | Réponse | Source (texte et article) |
|---|---|---|
| Le RGPD s'applique-t-il à ce traitement ? | Oui, selon le scénario : Hudson Cab Europe est une filiale établie à Paris et gère le traitement dans le cadre des activités de cet établissement. Le fait que les chauffeurs soient à New York ne l'écarte pas. | RGPD, article 3 §1 ; règlement (UE) 2016/679, publié au JOUE le 4 mai 2016. |
| Pourquoi, alors que les chauffeurs ne sont pas en Europe ? | L'article 3 §1 se fonde ici sur l'établissement européen, et non sur la résidence des chauffeurs ni sur la région Snowflake. L'article 3 §2 vise une autre situation : une organisation sans établissement dans l'UE qui cible des personnes se trouvant dans l'UE ; ce n'est pas le fondement de la conclusion dans ce brief. Les fichiers décrivent des personnes identifiables : `first_name`, `last_name`, `email`, `phone`, `birth_date`, `tlc_license_number`, `driver_id`, et les services reliés par `driver_id`. | RGPD, articles 3 §1, 3 §2 et 4 §1 ; fichiers `data/drivers.csv`, `data/driver_shifts.csv`. |
| Qui est responsable du traitement ? Qui est sous-traitant ? | Le contexte précise que Hudson Cab Europe décide désormais de ce que deviennent les données : elle est donc, selon les faits du brief, responsable du traitement pour les finalités et moyens qu'elle détermine (article 4 §7). Hudson Cab Partners reste l'employeur et l'origine du fichier ; son rôle exact doit être analysé traitement par traitement : responsable distinct, responsable conjoint ou autre rôle selon les décisions réellement prises. Snowflake est un sous-traitant ultérieur si, selon le contrat, il traite/héberge les données pour Hudson Cab Europe et sur ses instructions. Ne pas confondre filiale chargée de la gestion et prestataire cloud. | RGPD, articles 4 §7 et §8, 26 et 28 ; `CONTEXTE_BRIEF.md` (« elle qui décide désormais »). À confirmer dans les accords intragroupe et le contrat Snowflake. |
| Quelle autorité de contrôle est compétente ? | La CNIL est l'autorité française à consulter pour l'établissement parisien. Si le traitement est transfrontalier dans plusieurs États de l'UE, l'autorité chef de file dépend de l'établissement principal et du lieu où sont prises les décisions effectives ; ce point doit être vérifié. Le fait que les chauffeurs soient à New York ne rend pas à lui seul une autorité américaine compétente au titre du RGPD. | RGPD, articles 55 et 56 ; à confirmer au regard de l'organisation effective du groupe. |

## 2. Le dispositif de veille

| Source | Type (officielle, professionnelle…) | Ce qu'on y surveille | Fréquence | Outil de suivi |
|---|---|---|---|---|
| [EUR-Lex — RGPD, règlement (UE) 2016/679](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=fr) | Officielle, texte juridique de l'UE | Modifications et jurisprudence sur champ territorial, rôles, principes, droits, transferts et sécurité | Mensuelle, et avant toute mise en production | Alerte de recherche EUR-Lex ou revue manuelle du Journal officiel de l'UE ; abonnement à configurer |
| [CEPD — flux officiel des publications](https://www.edpb.europa.eu/feed/publications_en) | Officielle, comité européen de la protection des données | Lignes directrices, avis et décisions, notamment sur l'article 3, les responsables/sous-traitants et les transferts | Mensuelle | Lecteur RSS (par exemple Thunderbird ou Inoreader) ; abonnement et capture à faire |
| [CNIL — durées de conservation](https://www.cnil.fr/fr/les-durees-de-conservation-des-donnees) et [référentiel RH](https://www.cnil.fr/fr/referentiel-durees-conservation-donnees-rh) | Officielle, autorité française | Recommandations et références françaises de conservation ; vérifier le champ d'application national avant de les transposer à des salariés de New York | Trimestrielle | Lettre d'information CNIL ou lecteur RSS ; abonnement et capture à faire |
| [Snowflake — Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel), [Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe) et [`COPY INTO`](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table) | Documentation technique de l'éditeur, pas une source de droit | Durées et possibilité de restauration, comportement de Fail-safe, purge effective des fichiers de stage | À chaque changement de configuration/contrat et revue trimestrielle | Notes de version Snowflake et revue de la configuration du compte |

Responsables de lecture : le developpeur data, puis le responsable du traitement/Hudson Cab Europe avec le DPO ou le conseil juridique. Pour satisfaire l'exercice, s'abonner réellement à un flux ou une lettre d'information et enregistrer la capture dans `docs/` ; cette note ne prétend pas que cela a déjà été fait.

## 3. Les fiches de veille

Au moins quatre fiches. Une fiche = un texte, une recommandation ou une décision.

### Fiche 1 — Champ territorial et rôles des sociétés

- **Source** : Union européenne, règlement (UE) 2016/679, articles 3 §1, 4 §7-8, 26 et 28, [EUR-Lex](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=fr).
- **Date** : publié le 4 mai 2016 · consulté le 2 novembre 2026.
- **Ce que dit le texte** : le RGPD couvre un traitement réalisé dans le cadre des activités d'un établissement de l'UE, même si les personnes sont hors UE. Le responsable détermine les finalités et les moyens ; le sous-traitant traite pour son compte et selon ses instructions. Des entités peuvent être responsables conjointes si elles déterminent ensemble les finalités et moyens.
- **Ce que cela change pour notre entrepôt** : le traitement RH Snowflake est dans le champ du RGPD au vu de l'établissement de Hudson Cab Europe à Paris. D'après le contexte, Hudson Cab Europe décide désormais des données et est donc responsable pour cette activité ; Hudson Cab Partners demeure employeur, mais son rôle exact doit être documenté. Snowflake est à qualifier comme sous-traitant ultérieur dans les contrats. Les tables `RAW.DRIVERS`, `RAW.DRIVER_SHIFTS`, `MARTS.DIM_DRIVER` et `MARTS.MART_DRIVER_MONTHLY` contiennent des données personnelles, y compris les colonnes d'activité rattachées par `driver_id`.
- **Action** : à faire dans ce brief : consigner les rôles et vérifier la région avec `SELECT CURRENT_REGION();`. À signaler au DPO/conseil : accords intragroupe, contrat de sous-traitance Snowflake et éventuel transfert ou accès depuis un pays tiers.

### Fiche 2 — Principes, minimisation et qualité

- **Source** : Union européenne, RGPD, articles 5, 24, 25, 30 et 32, [EUR-Lex](https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=fr).
- **Date** : publié le 4 mai 2016 · consulté le 2 novembre 2026.
- **Ce que dit le texte** : les données doivent être traitées pour des finalités déterminées, limitées au nécessaire, exactes, conservées pendant une durée justifiée et protégées contre les accès non autorisés. Le responsable doit pouvoir démontrer les mesures prises ; les contrôles d'accès et la sécurité doivent être adaptés au risque.
- **Ce que cela change pour notre entrepôt** : justifier la présence de chaque champ RH et de chaque copie dans RAW, STAGING et MARTS ; limiter les rôles, masquer ou supprimer les colonnes non nécessaires, et tracer les accès. Les contrôles `licence_unique`, `email_valide`, `dates_coherentes` et `service_rattache` aident à détecter des erreurs, mais ne prouvent pas à eux seuls l'exactitude globale ni l'exercice des droits.
- **Action** : à faire dans ce brief : documenter finalités, colonnes, accès et résultats des contrôles ; tester les rôles. À signaler si des colonnes détaillées de trajets ou de revenus ne sont pas nécessaires à leurs destinataires.

### Fiche 3 — Durées de conservation RH

- **Source** : CNIL, « Les durées de conservation des données » et « Gestion des ressources humaines : la CNIL publie un référentiel de durées de conservation », [page générale](https://www.cnil.fr/fr/les-durees-de-conservation-des-donnees), [référentiel RH](https://www.cnil.fr/fr/referentiel-durees-conservation-donnees-rh).
- **Date** : pages consultées le 2 novembre 2026 ; la page et le référentiel RH indiquent une publication le 2 avril 2026.
- **Ce que dit le texte** : la durée en base active doit correspondre au temps nécessaire à la finalité ; un archivage intermédiaire peut être séparé et réservé à des personnes habilitées lorsqu'une obligation ou un contentieux le justifie. Le référentiel RH est un outil d'aide, non une règle obligatoire en soi, et la CNIL précise que ses références de droit national ne couvrent pas les obligations d'autres pays.
- **Ce que cela change pour notre entrepôt** : la règle R1 de cinq ans après la fin du contrat n'est pas validée par le seul RGPD. Il faut relier cette durée à chaque finalité et aux textes applicables à l'employeur et aux contrats new-yorkais. La purge doit toucher chaque copie et les dérivés personnels, notamment `driver_name` et les services liés par `driver_id` ; séparer les archives nécessaires des tables opérationnelles.
- **Action** : à signaler à la direction et au conseil juridique : justifier les cinq ans au regard du droit applicable à New York et de chaque catégorie de données ; ne pas appliquer automatiquement une durée française aux chauffeurs new-yorkais.

### Fiche 4 — Time Travel et Fail-safe Snowflake

- **Source** : Snowflake, [Understanding & using Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel) et [Understanding and viewing Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe).
- **Date** : documentation consultée le 2 novembre 2026.
- **Ce que dit la documentation** : un réglage de rétention d'un jour limite normalement Time Travel à un jour pour les données modifiées/supprimées. Pour les tables permanentes, Fail-safe intervient ensuite pendant sept jours ; les données ne sont plus interrogeables par le client, mais Snowflake peut tenter une récupération. Des requêtes Time Travel longues peuvent retarder le passage à Fail-safe.
- **Ce que cela change pour notre entrepôt** : R2 peut empêcher la restauration par les utilisateurs via Time Travel après un jour, mais ne garantit pas la disparition définitive après un jour. Avec des tables permanentes, le délai technique documenté est d'environ un jour de Time Travel plus sept jours de Fail-safe, sans compter un éventuel retard de requête. Vérifier la rétention effective de chaque table RH, et décrire précisément à qui la restauration reste possible.
- **Action** : à faire dans ce brief : tester Time Travel et documenter la limite Fail-safe dans le registre. À signaler au conseil : la compatibilité entre R2, une demande d'effacement et la récupération exceptionnelle opérée par Snowflake.

### Fiche 5 — Suppression des fichiers du stage

- **Source** : Snowflake, [`COPY INTO <table>` — option `PURGE`](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table) ; RGPD, articles 5 §1 f et 32.
- **Date** : documentation consultée le 2 novembre 2026 ; RGPD publié le 4 mai 2016.
- **Ce que dit le texte** : `PURGE = TRUE` demande à Snowflake de retirer du stage les fichiers chargés avec succès, mais l'opération de purge peut échouer sans renvoyer d'erreur. Le RGPD impose des mesures de sécurité adaptées ; il ne prescrit pas cette option SQL particulière.
- **Ce que cela change pour notre entrepôt** : la règle R3 est un contrôle utile de minimisation et de réduction du risque, mais il faut vérifier le stage avec `LIST @NYC_TAXI.RAW.RH_STAGE;`. Cette suppression ne purge pas les tables, les copies dans MARTS, Time Travel ou Fail-safe, ni une éventuelle copie locale ou Git.
- **Action** : à faire dans ce brief : conserver `PURGE = TRUE`, vérifier que le stage est vide et s'assurer que les CSV ne sont pas publiés dans le dépôt. Compléter la purge distincte des tables selon R1/R2.

## 4. Le contrat face aux textes

Une ligne par règle du contrat de gouvernance (accès, conservation, qualité). Vous ne réécrivez pas le contrat : un écart se signale, il se reporte dans le README.

| Règle du contrat | Ce que disent les textes | Source | Conforme ? | Écart et proposition |
|---|---|---|---|---|
| R1 : suppression 5 ans après la fin du contrat | Le principe de limitation de conservation impose une durée justifiée par finalité ; le RGPD ne fixe pas ici une règle générale de cinq ans. Une conservation supplémentaire peut être justifiée par une obligation ou un contentieux, avec accès restreint/archivage. Le référentiel RH CNIL 2026 vise les personnels soumis au droit français et ne permet pas de trancher le cas new-yorkais. | RGPD, articles 5 §1 e et 17 ; CNIL, référentiel RH (2 avril 2026). | À confirmer | Justifier cinq ans pour chaque catégorie et vérifier le droit du travail, les obligations et délais de recours applicables à New York. Définir les règles pour toutes les copies et données dérivées, dont `driver_name` et `DRIVER_SHIFTS`. Transmettre tout écart au conseil et le signaler dans le README sans modifier le contrat. |
| R2 : Time Travel limité à 1 jour | Le délai d'un jour peut limiter Time Travel, mais Snowflake indique sept jours de Fail-safe après la rétention pour les tables permanentes. Fail-safe n'est pas accessible pour consultation/restauration par le client ; Snowflake peut tenter une récupération. | RGPD, articles 5 §1 e, 17 et 32 ; documentation Snowflake Time Travel et Fail-safe. | Partiellement conforme | Formuler R2 comme une limite de restauration par les rôles clients via Time Travel, sans promettre l'effacement définitif à J+1. Mesurer/documenter environ 8 jours au total pour des tables permanentes et demander au conseil de valider la compatibilité de l'exigence avec Fail-safe. |
| R3 : fichier RH retiré du stage | La suppression après chargement réduit les copies accessibles et contribue à la sécurité, mais le RGPD ne prescrit pas `PURGE`. Snowflake précise que la purge est une tentative qui peut échouer sans erreur visible. | RGPD, articles 5 §1 c/e/f et 32 ; Snowflake, `COPY INTO <table>`, option `PURGE`. | Conforme si vérifié | Garder `PURGE = TRUE`, vérifier avec `LIST` et retirer manuellement tout fichier restant. Cette règle ne remplace ni la purge des tables ni la maîtrise des copies locales/Git. |
| Matrice des accès (qui voit quoi) | Les principes de minimisation, protection dès la conception, sécurité et responsabilité démontrable justifient les accès limités par rôle, colonne et dépôt. Le RGPD n'impose pas cette matrice exacte : chaque accès doit répondre à un besoin réel et être réévalué. | RGPD, articles 5 §1 b/c/f, 24, 25, 30 et 32. | Conforme dans son principe, à tester | Tester chaque rôle avec rôles secondaires désactivés ; vérifier les données dérivées, notamment `driver_name`, l'accès des administrateurs et l'audit. Documenter la nécessité métier, les habilitations et les révocations. |
| Règles de qualité (contrat, section 6) | L'exactitude est un principe du RGPD. Les contrôles techniques sont des mesures utiles, mais ils ne suffisent pas seuls à démontrer l'exactitude, les mises à jour, les droits de rectification ou la conformité globale. | RGPD, articles 5 §1 d, 5 §2, 16 et 24. | Partiellement conforme | Implémenter les seuils contractuels, enregistrer les résultats et bloquer la reconstruction sur l'anomalie bloquante. Ajouter un processus pour corriger les données à la source, traiter les demandes de rectification et prouver le suivi des alertes. |

## 5. Ce que la veille ne tranche pas

À soumettre au DPO et au conseil juridique de Hudson Cab Europe, avec la direction RH/juridique de Hudson Cab Partners : (1) qui détermine réellement les finalités et moyens, et faut-il formaliser une responsabilité conjointe au titre de l'article 26 ou un contrat de sous-traitance au titre de l'article 28 ? (2) quelle base légale de l'article 6 et quelles informations/droits s'appliquent aux chauffeurs ? (3) quelles règles de droit du travail et durées de conservation de New York s'appliquent, et les cinq ans de R1 sont-ils justifiés ? (4) quelle est la région Snowflake réelle (`SELECT CURRENT_REGION();`), quels accès de support ou transferts hors EEE existent, et quelles garanties du chapitre V sont requises ? (5) comment concilier R2 et le Fail-safe de sept jours des tables permanentes ? (6) les données de services, heures et revenus sont-elles nécessaires et proportionnées pour chaque rôle ?
