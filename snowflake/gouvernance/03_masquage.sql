-- politiques de masquage : elles sont attachées à un tag, et non à une colonne. Toute colonne portant le tag est protégée.

USE SECONDARY ROLES NONE;
USE ROLE GOUVERNANCE;
USE WAREHOUSE NYC_TAXI_WH;

CREATE MASKING POLICY IF NOT EXISTS NYC_TAXI.GOUVERNANCE.MASK_TEXTE
  AS (val STRING) RETURNS STRING -> val;

-- Rejouable, étape 2 : écrire le vrai corps. ALTER ... SET BODY fonctionne même si elle est attachée.
ALTER MASKING POLICY NYC_TAXI.GOUVERNANCE.MASK_TEXTE SET BODY ->
  CASE
    -- L'exception : la politique lit la valeur du tag de la colonne en cours de lecture.
    -- Une colonne taguée 'identifiant' reste visible de tous (pour compter et joindre).
    WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('NYC_TAXI.GOUVERNANCE.PII') = 'identifiant'
      THEN val
    -- Le pipeline voit tout en clair : s'il lisait un masque, il recopierait le masque.
    WHEN CURRENT_ROLE() = 'EX_PIPELINE'
      THEN val
    -- Le vendeur appelle ses clients : nom et téléphone en clair.
    WHEN CURRENT_ROLE() = 'EX_VENDEUR'
         AND SYSTEM$GET_TAG_ON_CURRENT_COLUMN('NYC_TAXI.GOUVERNANCE.PII') IN ('nom', 'telephone')
      THEN val
    -- Un masque partiel : on garde le domaine de l'e-mail.
    WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('NYC_TAXI.GOUVERNANCE.PII') = 'email'
      THEN REGEXP_REPLACE(val, '.+@', '*****@')
    ELSE '*****'
  END;
