-- Création du trigger B_UDX_TA_PT_TOPO_F_RECAL_LOG
/*
Objectif : versionner toutes les modifications/suppressions de TA_POINT_TOPO_F_RECAL afin de pouvroi revenir à un état antérieur.
*/

create or replace TRIGGER B_UDX_TA_POINT_TOPO_F_RECAL
    BEFORE UPDATE OR DELETE ON TA_POINT_TOPO_F_RECAL
    FOR EACH ROW
DECLARE
    username varchar(30);
    BEGIN
        SELECT sys_context('USERENV','OS_USER') into username from dual;  
        IF UPDATING THEN
             INSERT INTO GEO.TA_POINT_TOPO_F_RECAL_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_POI_LN, GEO_POI_LA, GEO_POI_AG_ORIENTATION, GEO_POI_HA, GEO_POI_AG_INCLINAISON, GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
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
            INSERT INTO GEO.TA_POINT_TOPO_F_RECAL_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_POI_LN, GEO_POI_LA, GEO_POI_AG_ORIENTATION, GEO_POI_HA, GEO_POI_AG_INCLINAISON, GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
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
                mail.sendmail('geotrigger@lillemetropole.fr',username || ' a provoque l''erreur : ' || SQLERRM,'ERREUR TRIGGER - geo/dev.TA_PT_TOPO_F_RECAL_LOG','bjacq@lillemetropole.fr');
    END;