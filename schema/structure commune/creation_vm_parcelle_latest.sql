-- 1. Creation de la vue

CREATE MATERIALIZED VIEW "G_DGFIP"."VM_PARCELLE_LATEST"
	(
	NUMERO_IDU,
	CODE_INSEE,
	PREFIXE,
	SECTION, 
	NUMERO_PARCELLE,
	CLA_INU,
	GEOM
	) AS 
SELECT 
  p.ID_PAR AS NUMERO_IDU,
  p.ID_COM AS CODE_INSEE,
  p.PRE AS PREFIXE,
  p.SECTION AS SCTION,
  p.PARCELLE AS NUMERO_PARCELLE,
  CAST(21 as number(8,0)) AS CLA_INU,
  p.GEOM AS GEOM
FROM 
	S_EDIGEO.PARCELLE p
;


-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_PARCELLE_LATEST',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 685041.1, 719322.2, 0.005),SDO_DIM_ELEMENT('Y', 7044713.4, 7077570.9, 0.005)),
    2154
);


-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW G_DGFIP.VM_PARCELLE_LATEST 
ADD CONSTRAINT VM_PARCELLE_LATEST_PK 
PRIMARY KEY (NUMERO_IDU);


-- 4. Création de l'index spatial
CREATE INDEX VM_PARCELLE_LATEST_SIDX
ON G_DGFIP.VM_PARCELLE_LATEST (GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);


-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_DGFIP.VM_PARCELLE_LATEST  IS 'Vue matérialisée proposant les parcelles actuelles sur le prérimètre de la MEL.';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.NUMERO_IDU IS 'Clé primaire de chaque parcelle, concatenation, CODE_INSEE + PREFIXE + SECTION + NUMERO_PARCELLE.';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.CODE_INSEE IS 'Code INSEE de la parcelle sur 5 caractères';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.PREFIXE IS 'PREFIXE de la section cadastrale de la parcelle sur 3 caractères';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.SECTION IS 'SECTION cadastrale de la parcelle sur 2 caractères.';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.NUMERO_PARCELLE IS 'Numéro de la parcelle sur 4 caractères';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.CLA_INU IS 'CLA_INU des parcelles le CLA_INU est un identifiants de caractérisation d''un objet.';
COMMENT ON COLUMN G_DGFIP.VM_PARCELLE_LATEST.GEOM IS 'Géométrie de l''objet.';