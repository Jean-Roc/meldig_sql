# FICHE DE CREATION DES OBJETS DANS ORACLE

## Connaître les tablespaces accessibles depuis un schéma

``` SQL
SELECT *
FROM USER_TABLESPACES;
```

## Création d'une clé primaire

### Pour une table

``` SQL
ALTER TABLE TABLE_NAME
  ADD CONSTRAINT TABLE_PK PRIMARY KEY("OBJECTID") USING INDEX TABLESPACE "INDX_...";
```

### Pour une vue

Créer une clé primaire sur une vue est une règle de bonne pratique qui permet à des outils tiers (GEO, DynMap, Elyx) utilisant la vue de trouver quel champ contient la clé. Quand un utilisateur charge une vue dans QGIS, il doit indiquer lui-même quel champ constitue la clé primaire pour pouvoir afficher la vue. 

``` SQL
ALTER VIEW VIEW_NAME
  ADD CONSTRAINT VIEW_PK PRIMARY KEY (OBJECTID) DISABLE);
```

## Création de Métadonnées spatiales

``` SQL
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('TABLE_NAME', 'GEOM', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 2154);

COMMIT;
```

## Création des index spatiaux

``` SQL
CREATE INDEX #TABLE#_SIDX
ON TABLE_NAME(GEOM)
    INDEXTYPE IS MDSYS.SPATIAL_INDEX
    PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=INDX_..., work_tablespace=DATA_TEMP');
```

## Création des index (non-spatiaux)

``` SQL
CREATE UNIQUE INDEX TABLE_NAME_CHAMP_IDX ON TABLE_NAME("CHAMP") TABLESPACE "INDX_...";
```

## Ajout de commmentaires

### Commentaire de table/vue matérialisée :

``` SQL
COMMENT ON TABLE TABLE_NAME IS 'COMMENT';
```

### Commentaire de vue :

``` SQL
COMMENT ON VIEW VIEW_NAME IS 'COMMENT';
```

### Commentaire de champ :

``` SQL
COMMENT ON COLUMN TABLE_NAME.COLUMN_NAME IS 'COMMENT';
```

## Gestion des droits

Exemple : pour donner un droit de lecture aux administrateurs

``` SQL
GRANT SELECT ON TABLE_NAME TO G_ADT_DSIG_ADM;
```

## Incrémentation de clé primaire

### Création de la séquence d'incrémentation :

``` SQL
CREATE SEQUENCE S_TABLE_NAME INCREMENT BY 1 START WITH 1 NOCACHE;
```

### Création du trigger d'incrémentation :

``` SQL
CREATE OR REPLACE TRIGGER B_IXX_TABLE_NAME
  BEFORE INSERT ON TABLE_NAME FOR EACH ROW
  BEGIN
    :new.OBJECTID := S_TABLE_NAME.nextval;
  END;
```

## Création de contraintes

### Ajout d'une clé étrangère :

``` SQL
ALTER TABLE TABLE_NAME
  ADD CONSTRAINT TABLE_NAME_CHAMP_FK FOREIGN KEY ("COLUMN_NAME") REFERENCES TABLE_NAME_REF("COLUMN_NAME") --ON DELETE CASCADE/SET NULL;
```

### Ajout d'une contrainte d'unicité :

``` SQL
ALTER TABLE TABLE_NAME
  ADD CONSTRAINT TABLE_NAME_CHAMP_UQ UNIQUE ("COLUMN_NAME");
```

## Ajout d'une colonne dans une table

``` SQL
ALTER TABLE TABLE_NAME
  ADD COLUMN_NAME DATA_TYPE;
```

## Suppression d'une colonne dans une table

``` SQL
ALTER TABLE TABLE_NAME
  DROP COLUMN_NAME;
```

## Création/suppresion d'objets

### Création d'une table :

``` SQL
-- 1. Création de la table
CREATE TABLE schema_name.table_name (
    champ1,
    champ2,
    champ3
);

-- 2. Commentaires de la tables
COMMENT ON TABLE TABLE_NAME IS '...';
COMMENT ON COLUMN table_name.champ1 IS '...';
COMMENT ON COLUMN table_name.champ2 IS '...';
COMMENT ON COLUMN table_name.champ3 IS '...';

-- 3. Création de la clé primaire
ALTER TABLE TABLE ADD CONSTRAINT TABLE_PK PRIMARY KEY("OBJECTID") USING INDEX TABLESPACE "INDX_...";

-- 4. Création de l'auto-incrémentation de la clé primaire (oracle 11g, mais pas 12c)
CREATE SEQUENCE S_TABLE_NAME INCREMENT BY 1 START WITH 1 NOCACHE;

CREATE OR REPLACE TRIGGER B_IXX_TABLE_NAME
BEFORE INSERT ON TABLE_NAME FOR EACH ROW
BEGIN
  :new.OBJECTID := S_TABLE_NAME.nextval;
END;

-- 5. Création des métadonnées spatiales de la table
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('TABLE_NAME', 'GEOM', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 2154);
COMMIT;

-- 6. Création de l'index spatial
CREATE INDEX TABLE_SIDX
ON TABLE_NAME(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=INDX_..., work_tablespace=DATA_TEMP');

-- 7. Droit de lecture de la table aux administrateurs
GRANT SELECT ON TABLE_NAME TO G_ADT_DSIG_ADM;
```

### Suppression d'une table :

``` SQL
DROP TABLE TABLE_NAME CASCADE CONSTRAINTS;
DROP SEQUENCE S_TABLE_NAME;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TABLE_NAME';
```

### Création d'une vue :

``` SQL
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW schema_name.view_name (
    champ1,
    champ2,
    champ3,
    CONSTRAINT "view_name_PK" PRIMARY KEY("CHAMP1") DISABLE
)
AS

SELECT
	champ1,
	champ2,
	champ3
FROM
	schema_name.table_name;
    
-- 2. Création des commentaires de la vue
COMMENT ON TABLE view_name IS '...';
COMMENT ON COLUMN view_name.champ1 IS '...';
COMMENT ON COLUMN view_name.champ2 IS '...';
COMMENT ON COLUMN view_name.champ3 IS '...';

-- 3. Création des métadonnées spatiales de la vue
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('VIEW_NAME', 'GEOM', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 2154);
COMMIT;
```

### Suppression d'une vue :

``` SQL
DROP VIEW view_name;
```

### Création d'une vue matérialisée :

``` SQL
-- 1. Création de la vue matérialisée (VM)
CREATE MATERIALIZED VIEW schema_name.vm_materialized_view_name
USING INDEX
TABLESPACE tablespace_name
REFRESH ON DEMAND
FORCE  
DISABLE QUERY REWRITE
AS

SELECT
	champ1,
	champ2,
	champ3
FROM
	schema_name.table_name;
    
-- 2. Création des commentaires de la vue matérialisée
COMMENT ON MATERIALIZED VIEW materialized_view_name IS '...';
COMMENT ON COLUMN materialized_view_name.champ1 IS '...';
COMMENT ON COLUMN materialized_view_name.champ2 IS '...';
COMMENT ON COLUMN materialized_view_name.champ3 IS '...';

-- 3. Création des métadonnées spatiales de la VM
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES ('MATERIALIZED_VIEW_NAME', 'GEOM', SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 2154);
COMMIT;
```

### Suppression d'une vue matérialisée :

``` SQL
DROP MATERIALIZED VIEW materialized_view_name;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'MATERIALIZED_VIEW_NAME';
```

## Création de trigger :

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_IUD_TABLE_NAME
    BEFORE INSERT ON TABLE_NAME
    FOR EACH ROW

	DECLARE
		...

	BEGIN
	    ...
	END;
```

### Règles de nommage :

Si le trigger se déclenche avant l'insertion (BEFORE INSERT), alors utilisez le préfixe 'B_' ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_..._TABLE_NAME
BEFORE INSERT ON TABLE_NAME
```
Si le trigger se déclenche après l'insertion (AFTER INSERT), alors utilisez le préfixe 'A_' ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.A_..._TABLE_NAME
AFTER INSERT ON TABLE_NAME
```

S'il s'agit d'une insertion seule, rajoutez 'IXX' -> 'B_IXX_TABLE_NAME' ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_IXX_TABLE_NAME
BEFORE INSERT ON TABLE_NAME
```

S'il s'agit d'une mise à jour seule, rajoutez 'UXX' -> 'B_UXX_' ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_UXX_TABLE_NAME
BEFORE INSERT ON TABLE_NAME
```

S'il s'agit d'une Suppression seule, rajoutez 'DXX' -> 'B_DXX_' ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_DXX_TABLE_NAME
BEFORE INSERT ON TABLE_NAME
```

**Les deux 'XX' placés derrière l'initiale d'insertion/mise à jour/suppression signifie que le trigger marche UNIQUEMENT pour une action.**

Si un trigger peut être déclenché par deux actions, alors, vous pouvez mélanger les préfixes -> 'B_IUX_TABLE_NAME' signifie que le trigger se déclenche avant l'insertion ou la mise de la table dont le nom figure dans le nom du trigger ;

``` SQL
CREATE OR REPLACE TRIGGER SCHEMA_NAME.B_IUX_TABLE_NAME
BEFORE INSERT ON TABLE_NAME
```
