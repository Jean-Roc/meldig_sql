/*
Objectif : créer une table de versionnement pour la table TA_POINT_TOPO_F, qui récupère toutes les modifications et suppression faites sur chaque objet de la table TA_POINT_TOPO_F (production).

Méthode :
Pour la table de production, on créé : 
  1. une table de versionnement ;
  2. un trigger qui incrémente la table de versionnement avec les modifications qu'il récupère dans la table de production ;
*/

-- 1. Création de la table de versionnement :
-- 1.1. Création de la table de versionnement TA_POINT_TOPO_F_LOG
CREATE TABLE GEO.TA_POINT_TOPO_F_LOG(
   OBJECTID NUMBER(38,0) NOT NULL ENABLE, 
  FID_IDENTIFIANT NUMBER(38,0) NOT NULL ENABLE, 
  CLA_INU NUMBER(8,0) NOT NULL ENABLE, 
  GEO_REF VARCHAR2(13 BYTE), 
  GEO_INSEE CHAR(3 BYTE), 
  GEOM SDO_GEOMETRY, 
  GEO_DV DATE, 
  GEO_DF DATE, 
  GEO_TEXTE VARCHAR2(2048 BYTE), 
  GEO_POI_LN NUMBER(8,0), 
  GEO_POI_LA NUMBER(8,0), 
  GEO_POI_AG_ORIENTATION NUMBER(5,2), 
  GEO_POI_HA NUMBER(8,0), 
  GEO_POI_AG_INCLINAISON NUMBER(5,2), 
  GEO_TYPE CHAR(1 BYTE), 
  GEO_NMN VARCHAR2(20 BYTE), 
  GEO_DM DATE,
  MODIFICATION NUMBER(38,0) NOT NULL ENABLE
);

-- 1.2. Création des commentaires pour la table et ses attributs
   COMMENT ON TABLE GEO.TA_POINT_TOPO_F_LOG  IS 'Table de versionnement de la table TA_POINT_TOPO_F. Elle contient toutes les mises à jour (à partir du 14.02.2020) et les suppressions de la table de production.';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.OBJECTID IS 'Identifiant interne de l''objet geographique';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.FID_IDENTIFIANT IS 'Identifiant de l''objet qui est/était présent dans la table de production.';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.CLA_INU IS 'Reference a la classe a laquelle appartient l''objet';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_REF IS 'Identifiant metier. Non obligatoire car certain objet geographique n''ont pas d''objet metier associe.';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_INSEE IS 'Code insee de la commune sur laquelle se situe l''objet';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEOM IS 'Geometrie ORACLE de l''objet';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_DV IS 'Date de debut de validite de l''objet';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_DF IS 'Date de fin de validite de l''objet.';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_TEXTE IS 'Texte de commentaire';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_POI_LN IS 'Longueur de l''objet (en cm)';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_POI_LA IS 'Largeur de l''objet (en cm)';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_POI_AG_ORIENTATION IS 'Orientation de l''objet (en degre)';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_POI_HA IS 'Hauteur de l''objet (en cm)';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_POI_AG_INCLINAISON IS 'Inclinaison de l''objet (en degre, par rapport a la verticale).';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_TYPE IS 'Type de geometrie de l''objet geographique';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_NMN IS 'Auteur de la derniere modification';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.GEO_DM IS 'Date de deniere modification de l''objet';
   COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_LOG.MODIFICATION IS 'Type de modification effectuée sur la donnée : 1 = mise à jour, 0 = suppression';

-- 1.3. Création de la clé primaire de la table
ALTER TABLE TA_POINT_TOPO_F_LOG 
ADD CONSTRAINT TA_POINT_TOPO_F_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "INDX_GEO";

-- 1.4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TA_POINT_TOPO_F_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684000, 721000, 0.005),SDO_DIM_ELEMENT('Y', 7044000, 7079000, 0.005),MDSYS.SDO_DIM_ELEMENT('Z', -1000, 10000, 0.005)), 
    2154
);
COMMIT;

-- 1.5. Création de l'index spatial sur le champ geom. Le type de géométrie est : point en 3D.
CREATE INDEX TA_POINT_TOPO_F_LOG_SIDX
ON TA_POINT_TOPO_F_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX PARAMETERS (' LAYER_GTYPE = MULTIPOINT WORK_TABLESPACE=DATA_TEMP TABLESPACE=INDX_GEO');

-- 1.6. Création de la séquence d'auto-incrémentation
CREATE SEQUENCE SEQ_TA_POINT_TOPO_F_LOG
START WITH 1 INCREMENT BY 1;

-- 1.7. Création du trigger d'incrémentation de la clé primaire
CREATE OR REPLACE TRIGGER "GEO"."BEF_TA_POINT_TOPO_F_LOG" 
BEFORE INSERT ON TA_POINT_TOPO_F_LOG
FOR EACH ROW

BEGIN
  :new.objectid := SEQ_TA_POINT_TOPO_F_LOG.nextval;
END;

-- 2. Création du trigger de récupération des modifications ou des suppressions de la table de production (TA_POINT_TOPO_F) qu'il insére dans la table de versionnement (TA_POINT_TOPO_F_LOG)
CREATE OR REPLACE TRIGGER trig_TA_POINT_TOPO_F_LOG
    BEFORE UPDATE OR DELETE ON TA_POINT_TOPO_F
    FOR EACH ROW
DECLARE
    username varchar(30);
    BEGIN
        SELECT sys_context('USERENV','OS_USER') into username from dual;  
        IF UPDATING THEN
             INSERT INTO GEO.TA_POINT_TOPO_F_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_POI_LN, GEO_POI_LA, GEO_POI_AG_ORIENTATION, GEO_POI_HA, GEO_POI_AG_INCLINAISON, GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
            VALUES( :old.objectid,
                :old.cla_inu,
                :old.geo_ref,
                :old.geo_insee,
                :old.geom,
                :old.geo_dv,
                :old.geo_df,
                :old.geo_texte,
                :old.geo_poi_ln,
                :old.geo_poi_la,
                :old.geo_poi_ag_orientation,
                :old.geo_poi_ha,
                :old.geo_poi_ag_inclinaison,
                :old.geo_type,
                username,
                sysdate,
                1
            );
        END IF;
        IF DELETING THEN
            INSERT INTO GEO.TA_POINT_TOPO_F_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_POI_LN, GEO_POI_LA, GEO_POI_AG_ORIENTATION, GEO_POI_HA, GEO_POI_AG_INCLINAISON,  GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
            VALUES( :old.objectid,
                :old.cla_inu,
                :old.geo_ref,
                :old.geo_insee,
                :old.geom,
                :old.geo_dv,
                :old.geo_df,
                :old.geo_texte,
                :old.geo_poi_ln,
                :old.geo_poi_la,
                :old.geo_poi_ag_orientation,
                :old.geo_poi_ha,
                :old.geo_poi_ag_inclinaison,
                :old.geo_type,
                username,
                sysdate,
                0
            );
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                mail.sendmail('geotrigger@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - geo.TA_POINT_TOPO_F_LOG','bjacq@lillemetropole.fr', 'sysdig@lillemetropole.fr');
    END;