/*
La table TA_LIBELLE_LONG regroupe les libelles long pouvant être pris par les objets de la base.

*/
-- 1. Création de la table
CREATE TABLE G_GEO.TA_LIBELLE_LONG(
	objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
	valeur VARCHAR2(255)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_GEO.TA_LIBELLE_LONG IS 'Table regroupant les libelles long pouvant être pris par les objets, états ou actions présents dans le schéma.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE_LONG.objectid IS 'Clé primaire de la table TA_LIBELLE_LONG.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE_LONG.valeur IS 'Valeur pouvant être prises par les objets, états ou actions présents dans le schéma.';

-- 3. Création de la clé primaire
ALTER TABLE G_GEO.TA_LIBELLE_LONG
ADD CONSTRAINT TA_LIBELLE_LONG_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_GEO.TA_LIBELLE_LONG TO G_ADMIN_SIG;