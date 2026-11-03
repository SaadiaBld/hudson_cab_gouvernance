# Registre du traitement — données du personnel

Copier ce fichier sous le nom `docs/REGISTRE.md`. Il se remplit en deux temps :

- **Partie 1, jour 1** : l'inventaire des données personnelles des deux fichiers, avant tout chargement ;
- **Partie 2, jour 3** : la fiche de registre, qui s'appuie sur l'inventaire et sur ce que vous avez construit.

---

## Partie 1 — Inventaire des données personnelles (jour 1)

Une donnée personnelle est une information qui se rapporte à une personne identifiée ou identifiable. Trois cas à distinguer :

- **identifiant direct** : la colonne suffit à désigner la personne (un nom, un e-mail) ;
- **identifiant indirect** : la colonne ne suffit pas seule, mais permet d'identifier quelqu'un une fois combinée à d'autres (une date de naissance et un dépôt) ;
- **pas une donnée personnelle** : la colonne ne dit rien d'une personne.

### `drivers.csv` : les colonnes

| Colonne | Exemple de valeur | Donnée personnelle ? (direct, indirect, non) | Valeur du tag `DONNEE_PERSONNELLE` | Qui en a besoin, et pour quoi faire |
|---|---|---|---|---|
| `driver_id` | `D0001` | Indirecte : identifiant interne, qui désigne le chauffeur via le référentiel | `identifiant_interne` | Paie et pipeline : retrouver le dossier et relier les services au chauffeur |
| `first_name` | `Thomas` | Indirecte seule ; avec le nom, identifie le chauffeur | `nom` | Paie et responsables de dépôt : identifier le chauffeur |
| `last_name` | `Pierre` | Indirecte seule ; avec le prénom, identifie le chauffeur | `nom` | Paie et responsables de dépôt : identifier le chauffeur |
| `email` | `thomas.pierre1@post.example` | Directe : permet de contacter et reconnaître le chauffeur | `email` | Paie : contacter le chauffeur |
| `phone` | `+1 (917) 555-0161` | Directe : permet de contacter le chauffeur | `telephone` | Paie et responsables de dépôt : contacter le chauffeur |
| `birth_date` | `1957-07-24` | Indirecte : peut contribuer à identifier le chauffeur, notamment avec d'autres données | `date_naissance` | Paie : gestion du dossier ; analyste : seule l'année est utile selon le contrat |
| `tlc_license_number` | `5841963` | Directe : numéro officiel unique de licence | `identifiant_officiel` | Paie et responsables concernés : vérifier la licence |
| `depot` | `Bronx` | Indirecte dans cette table : rattachement professionnel relié au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie et responsables de dépôt : affectation et filtrage des chauffeurs |
| `hire_date` | `2010-11-12` | Indirecte : date professionnelle reliée au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie : ancienneté et gestion du contrat |
| `end_date` | vide (contrat en cours) | Indirecte : indique le statut du contrat du chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie : savoir si le contrat est terminé |

### `driver_shifts.csv` : les colonnes

| Colonne | Exemple de valeur | Donnée personnelle ? (direct, indirect, non) | Valeur du tag `DONNEE_PERSONNELLE` | Qui en a besoin, et pour quoi faire |
|---|---|---|---|---|
| `shift_id` | `S017747` | Indirecte dans le contexte du service ; identifiant du service, pas du chauffeur seul | Aucune valeur prévue dans la taxonomie du contrat | Pipeline : identifier et contrôler un service |
| `driver_id` | `D0317` | Indirecte : relie le service à un chauffeur | `identifiant_interne` | Paie et pipeline : rattacher l'activité au bon chauffeur |
| `shift_date` | `2025-03-03` | Indirecte : date d'activité reliée au chauffeur par `driver_id` | Aucune valeur prévue dans la taxonomie du contrat | Paie et analyste : suivre l'activité dans le temps |
| `depot` | `Brooklyn` | Indirecte dans le contexte du service : lieu de rattachement associé au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie et responsables de dépôt : filtrer l'activité par dépôt |
| `start_hour` | `19` | Indirecte dans le contexte du service : horaire associé au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie : vérifier les horaires ; analyste : analyser l'activité |
| `hours_worked` | `7.6` | Indirecte dans le contexte du service : durée de travail associée au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie : calculer et vérifier le temps travaillé |
| `trips_count` | `20` | Indirecte dans le contexte du service : activité associée au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie et analyste : suivre l'activité et les volumes |
| `revenue_usd` | `525.58` | Indirecte dans le contexte du service : revenu associé au chauffeur | Aucune valeur prévue dans la taxonomie du contrat | Paie et analyste : suivre les revenus |

Le tag est une métadonnée posée sur une colonne entière, pas une valeur ajoutée à chaque ligne. Les valeurs sont limitées par le contrat ; les données professionnelles liées aux services sont personnelles par association avec `driver_id`, mais leur catégorie n'est pas prévue dans la taxonomie actuelle. Il faut signaler cette limite plutôt que leur attribuer une valeur de tag inventée.
| | | | | |

### Où cette donnée est-elle copiée ?

Pour chaque colonne personnelle : la liste des tables et des vues de l'entrepôt où elle se retrouve, y compris sous une autre forme (colonne renommée, colonne calculée). À compléter au fil des trois jours.

| Colonne d'origine | Table ou vue | Colonne | Sous quelle forme |
|---|---|---|---|
| | | | |

### Ce qui a surpris

Deux ou trois lignes : une colonne plus sensible que prévu, une colonne dont personne n'a besoin, une donnée qui n'aurait pas dû être dans le fichier.

---

## Partie 2 — Fiche de registre (jour 3)

Le registre des activités de traitement décrit ce qu'une organisation fait des données personnelles qu'elle détient. Cette fiche en est une version réduite, limitée à ce qu'un Data Engineer peut renseigner et prouver. La trame complète est celle de la CNIL (lien dans les ressources).

Chaque réponse de la colonne de droite doit pouvoir être vérifiée dans l'entrepôt : indiquez la requête ou le fichier qui le prouve.

### Le traitement

| Rubrique | Réponse |
|---|---|
| Nom du traitement | |
| Finalité : à quoi servent ces données | |
| Personnes concernées | |
| Service responsable des données | |

### Les données

| Catégorie de données | Colonnes concernées | Tables où elles se trouvent |
|---|---|---|
| Identité | | |
| Coordonnées | | |
| Vie professionnelle | | |

### Qui y accède

| Rôle | Ce qu'il voit | Pourquoi il en a besoin | Preuve (requête ou test) |
|---|---|---|---|
| | | | |

### Combien de temps

| Règle | Comment elle est appliquée | Preuve |
|---|---|---|
| R1 : suppression 5 ans après la fin du contrat | | |
| R2 : pas de restauration au-delà de 1 jour | | |
| R3 : pas de fichier sur le stage | | |

Délai réel entre l'exécution de la purge et la disparition définitive d'une donnée dans Snowflake, en tenant compte de Time Travel et de Fail-safe : ______ jours.

### Comment on le contrôle

| Question | Réponse | Preuve |
|---|---|---|
| Peut-on dire qui a lu ces données la semaine dernière ? | | |
| Sait-on quand une donnée est fausse ? | | |
| Que se passe-t-il si le rôle des outils est compromis ? | | |

### Limites connues

Ce que votre mise en œuvre ne couvre pas : deux ou trois lignes, sans détour.
