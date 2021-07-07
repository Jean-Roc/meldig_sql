/*
Création de la table TA_POINT_TOPO_F_RECAL devant permettre aux topos de recaler les objets du plans topographique fin quand c'est nécessaire.
*/
-- 1. Création de la table TA_POINT_TOPO_F_RECAL
CREATE TABLE GEO.TA_POINT_TOPO_F_RECAL(
    OBJECTID NUMBER(38,0),
    CLA_INU NUMBER(38,0),
    GEO_REF VARCHAR2(13 BYTE),
    GEO_INSEE CHAR(3 BYTE),
    GEOM SDO_GEOMETRY,
    GEO_DV DATE,
    GEO_DF DATE,
    GEO_ON_VALIDE NUMBER(38,0),
    GEO_TEXTE VARCHAR2(2048 BYTE),
    GEO_POI_LN NUMBER(38,0),
    GEO_POI_LA NUMBER(38,0),
    GEO_POI_AG_ORIENTATION NUMBER(5,2),
    GEO_POI_HA NUMBER(8,0),
    GEO_POI_AG_INCLINAISON NUMBER(5,2),
    GEO_TYPE CHAR(1 BYTE),
    GEO_NMN VARCHAR2(20 BYTE),
    GEO_DS DATE,
    GEO_NMS VARCHAR2(20 BYTE),
    GEO_DM DATE,
    RECALAGE NUMBER(1,0)
);

-- 2. Création des commentaires de table
COMMENT ON TABLE GEO.TA_POINT_TOPO_F_RECAL IS 'TABLE permettant le recalage des objets du plan topographique fin quand c''est nécessaire. Cette table dispose d''une table de log - TA_POINT_TOPO_F_RECAL_LOG - enregistrant toutes les modifications des données.';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.OBJECTID IS 'Identifiant interne de l''objet geographique ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.CLA_INU IS 'Reference a la classe a laquelle appartient l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_REF IS 'Identifiant metier. Non obligatoire car certain objet geographique n''ont pas d''objet metier associe. Dans certains cas il peut contenir le numéro de dossier ta_gg_dossier d''origine du levé ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_INSEE IS 'Code insee de la commune sur laquelle se situe l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEOM IS 'Geometrie ORACLE de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_DV IS 'Date de debut de validite de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_DF IS 'Date de fin de validite de l''objet. ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_ON_VALIDE IS 'Statut valide O/N de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_TEXTE IS 'Texte de commentaire ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_POI_LN IS 'Longueur de l''objet (en cm) ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_POI_LA IS 'Largeur de l''objet (en cm) ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_POI_AG_ORIENTATION IS 'Orientation de l''objet (en degre) ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_POI_HA IS 'Hauteur de l''objet (en cm) ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_POI_AG_INCLINAISON IS 'Inclinaison de l''objet (en degre, par rapport a la verticale). ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_TYPE IS 'Type de geometrie de l''objet geographique ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_NMN IS 'Auteur de la derniere modification ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_DS IS 'Date de creation de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_NMS IS 'Auteur de la creation de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.GEO_DM IS 'Date de derniere modification de l''objet ';
COMMENT ON COLUMN GEO.TA_POINT_TOPO_F_RECAL.RECALAGE IS 'Champ permettant de distinguer les objets à recaler de ceux à ne pas toucher : 0 = objet à ne pas toucher ; 1 = objet à recaler';

-- 4. Création de la clé primaire
    ALTER TABLE GEO.TA_POINT_TOPO_F_RECAL 
    ADD CONSTRAINT TA_POINT_TOPO_F_RECAL_PK 
    PRIMARY KEY("OBJECTID") 
    USING INDEX TABLESPACE "INDX_GEO";

-- 5. Création des métadonnées spatiales
    INSERT INTO USER_SDO_GEOM_METADATA(
        TABLE_NAME, 
        COLUMN_NAME, 
        DIMINFO, 
        SRID
    )
    VALUES(
        'TA_POINT_TOPO_F_RECAL',
        'geom',
        SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005),SDO_DIM_ELEMENT('Z', -1000, 10000, 0.005)), 
        2154
    );
    COMMIT;

-- 6. Création de l'index spatial sur le champ geom
    CREATE INDEX TA_POINT_TOPO_F_RECAL_SIDX
    ON GEO.TA_POINT_TOPO_F_RECAL(GEOM)
    INDEXTYPE IS MDSYS.SPATIAL_INDEX
    PARAMETERS('layer_gtype=MULTIPOINT, tablespace=INDX_GEO, work_tablespace=DATA_TEMP');