Contexte du projet
La situation

Hudson Cab Partners exploite une flotte de taxis jaunes à New York, depuis trois dépôts : Bronx, Brooklyn et Queens. Vous venez de rejoindre l'équipe data, qui ouvre un entrepôt Snowflake pour un nouveau domaine : le personnel. La direction veut savoir quels dépôts et quels chauffeurs font tourner la flotte. Le service RH vous a donc transmis son fichier du personnel et le relevé des services de janvier à mars 2025.

Priya a aussitôt écrit le SQL qui construit une dimension chauffeur et une table d'activité mensuelle. Elle l'a fait vite, sans se demander ce que contenait le fichier. Or il contient des noms, des adresses e-mail, des téléphones, des dates de naissance et des numéros de licence. Trois services réclament déjà un accès : la paie, les responsables de dépôt, et Priya elle-même.

Personne ne sait dire aujourd'hui quelles colonnes de l'entrepôt décrivent une personne, qui les lit, ni ce que deviennent les données d'un chauffeur parti depuis dix ans. La direction a fixé les règles avec son conseil juridique. Elle vous demande de les mettre en œuvre avant d'ouvrir le moindre accès.

Un détail change tout : depuis cette année, le groupe a confié la gestion de ses données du personnel à Hudson Cab Europe, sa filiale installée à Paris. C'est elle qui porte l'entrepôt et l'équipe data, et elle qui décide désormais de ce que deviennent ces données. Le conseil juridique a rédigé le contrat de gouvernance avant ce transfert. Avant d'écrire la moindre politique, la direction veut savoir quelles règles s'imposent désormais à ces données et si le contrat les respecte.
La question à laquelle répondre

    Qui peut voir quelle donnée, pendant combien de temps, et peut-on s'y fier ?

Chaque choix des trois jours doit pouvoir se justifier par cette question.
Ce que vous allez construire
Image
Preview

    La veille réglementaire : un dispositif de veille, des fiches sur les textes qui s'appliquent, et la confrontation du contrat à ces textes.
    L'intégration du fichier RH : stage, tables RAW, chargement rejouable, puis les transformations fournies.
    Le catalogue : une description pour chaque table et chaque colonne, trois tags, une vue qui rassemble le tout.
    Les accès : quatre rôles métier, des politiques de masquage, une politique d'accès par ligne pilotée par une table de correspondance.
    La conservation et la qualité : des tâches Snowflake quotidiennes qui purgent, contrôlent, puis reconstruisent.
    La preuve : un cahier de tests des accès et une requête d'audit.

Les sources de données

    Chauffeurs : 1 fichier CSV ; 400 lignes, 10 colonnes ; data/drivers.csv du kit
    Services : 1 fichier CSV ; 25 951 lignes, 8 colonnes ; data/driver_shifts.csv du kit

Le fichier RH est fictif : on ne s'exerce pas à la gouvernance sur de vraies personnes. Aucun chauffeur n'existe et les adresses e-mail ne mènent nulle part. Il se traite pourtant comme un vrai fichier du personnel, et comme tout fichier venu d'un autre service, il contient des erreurs.
Ce qui vous est fourni

Un kit de démarrage : le script d'installation de Snowflake et celui du chargement, le guide étape par étape (GUIDE_BRIEF_GOUVERNANCE.md), le contrat de gouvernance (CONTRAT_GOUVERNANCE.md), les deux fichiers RH, les fichiers SQL de Priya, trois modèles de documents et des exemples commentés. L'étape 0 du guide explique chaque dossier et comment installer le kit.
Contraintes techniques

    Snowflake en édition Enterprise (voir l'étape 0 du guide).
    Les règles sont portées par des rôles, jamais par des utilisateurs nommés.
    Le rôle qui écrit les règles ne lit pas les données ; ACCOUNTADMIN non plus.
    Tout est écrit dans des fichiers SQL versionnés et rejouables : rien n'est saisi à la main dans l'interface.
    Les règles survivent à une exécution du pipeline.
    Aucun secret et aucune donnée personnelle dans le dépôt GitHub public.

Vocabulaire

    Donnée personnelle : information qui se rapporte à une personne identifiée ou identifiable
    Catalogue : l'inventaire documenté des données : ce que contient chaque table, d'où elle vient, qui en répond
    Tag : étiquette posée sur une table ou une colonne ; elle décrit, et peut déclencher une règle
    Politique de masquage : règle qui transforme la valeur d'une colonne selon le rôle qui la lit
    Politique d'accès par ligne : règle qui cache certaines lignes selon le rôle qui lit
    Minimisation : ne conserver et ne montrer que les données nécessaires à un usage
    Durée de conservation : délai au bout duquel une donnée doit être supprimée
    Time Travel, Fail-safe : les deux délais pendant lesquels Snowflake garde une donnée supprimée
    Lignage : le chemin d'une donnée, de sa source aux tables qui en dépendent
    Registre des traitements : document qui décrit ce qu'une organisation fait des données personnelles
    Rôle des outils : le rôle Snowflake avec lequel se font le chargement et les tâches planifiées : TRANSFORMER, créé à l'installation
    Dépôt : le garage d'où partent les taxis (Queens, Bronx, Brooklyn) ; à ne pas confondre avec votre dépôt GitHub

Modalités pédagogiques
Organisation

    Durée et format : 3 jours, en binôme, en autonomie accompagnée.
    Document de référence : CONTRAT_GOUVERNANCE.md. Il dit ce qui est exigé, pas comment le faire.
    Répartition : pendant qu'un membre écrit une politique, l'autre écrit le test qui la vérifie, puis vous échangez.
    Règle d'or : un test s'écrit avant la politique qu'il vérifie.
    Guide : GUIDE_BRIEF_GOUVERNANCE.md donne, pour chaque jour, les étapes, les fichiers à créer, les rôles à utiliser, les pièges et le résultat à obtenir. Commencez par son étape 0.

Le déroulé

    Jour 1, matin (sans code) : savoir quelles règles s'imposent aux données des chauffeurs, et si le contrat les respecte. Il en sort la note de veille et l'inventaire des données personnelles.
    Jour 1, après-midi : charger le fichier RH sans le publier, et documenter chaque table et chaque colonne. Aucune politique ce jour-là : on ne protège pas ce que l'on n'a pas inventorié.
    Jour 2 : décider qui voit quoi, l'écrire en tests, puis en politiques. Il en sort un cahier de tests entièrement vert.
    Jour 3 : purger, contrôler la qualité chaque jour, prouver qui a lu quoi, présenter.

Bonus : classification automatique de Snowflake comparée à votre inventaire ; alerte Snowflake quand une règle de qualité passe en ALERTE ; politique d'agrégation pour l'analyste.