  
/*
Requêtes nécessaires à la création de la vue matérialisée G_REFERENTIEL.ADMIN_IRIS.
Cette vue materialisée à pour but de restituer les données IRIS aux millesimes le plus récent.
*/
CREATE MATERIALIZED VIEW G_DGFIP.RVLLP_SECTION
	(
	ANNEE,
	IDU,
	SECTION,
	CODE_COMMUNE,
	NOM_COMMUNE,
	RVLLP,
	SOURCE,
	GEOM
	)
USING INDEX
TABLESPACE G_ADT_INDX
REFRESH ON DEMAND
FORCE  
DISABLE QUERY REWRITE AS


SELECT
    '2017' AS ANNEE,
	a.IDU,
    SUBSTR(a.IDU,7,8) AS SECTION,
	a.id_com AS CODE_COMMUNE,
	b.nom_commune AS NOM_COMMUNE,
	b."Secteur" AS RVLLP,
	'https://www.impots.gouv.fr/portail/www2/fichiers/professionnels/rvllp/secteur/secteur-59.ods' AS SOURCE
FROM
	G_DGFIP.SECTION_CADASTRALE_LMCU a
	RIGHT JOIN G_DGFIP.RVLLP b ON b.CODE_COM = a.CODE_COM
WHERE
    b."Section" IS NULL
UNION ALL SELECT
    '2017' AS ANNEE,
	a.IDU,
    SUBSTR(a.IDU,7,8) AS SECTION,
	a.id_com AS CODE_COMMUNE,
	b.nom_commune AS NOM_COMMUNE,
	b."Secteur" AS RVLLP,
	'https://www.impots.gouv.fr/portail/www2/fichiers/professionnels/rvllp/secteur/secteur-59.ods' AS SOURCE
FROM
	G_DGFIP.SECTION_CADASTRALE_LMCU a
	RIGHT JOIN G_DGFIP.RVLLP b ON 
                            (b.CODE_COM = a.CODE_COM
                            AND b.pre = a.pre
                            AND b."Section" = a.section)
WHERE
    b."Section" IS NOT NULL
;

COMMENT ON MATERIALIZED VIEW G_DGFIP.RVLLP_SECTION IS 'Vue proposant la répartition des différents secteurs fiscaux de la taxe dite RVLLP.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.ANNEE IS 'Millesime de la donnée.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.IDU IS 'Code IDU de la section CODE_COM sur trois caractère + prefixe de la section + section';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.SECTION IS 'Section de la parcelle sur deux caractère.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.CODE_COMMUNE IS 'Code de la commune.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.NOM_COMMUNE IS 'Nom de la commune.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.RVLLP IS 'Secteur de la Valeurs Locatives des Locaux Professionnels.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.Source IS 'Source de la donnée.';
COMMENT ON COLUMN G_DGFIP.RVLLP_SECTION.GEOM IS 'Géométrie de la donnée.';

-- 6. Création des métadonnées spatiales

INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
	)
VALUES(
    'RVLLP_SECTION',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
	);


-- 7. Création de la clé primaire
ALTER MATERIALIZED VIEW GEO.RVLLP_SECTION 
ADD CONSTRAINT rvllp_section_PK
PRIMARY KEY (IDU)
USING INDEX TABLESPACE "G_ADT_INDX";


-- 8. Création de l'index spatial
CREATE INDEX RVLLP_SECTION_SIDX
ON G_DGFIP.RVLLP_SECTION(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
	'sdo_indx_dims=2, 
	layer_gtype=MULTIPOLYGON, 
	tablespace=G_ADT_INDX, 
	work_tablespace=DATA_TEMP'
	);