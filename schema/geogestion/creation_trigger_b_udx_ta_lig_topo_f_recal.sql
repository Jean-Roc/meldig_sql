-- Création du trigger B_UDX_TA_LIG_TOPO_F_RECAL_LOG
/*
Objectif : versionner toutes les modifications/suppressions de TA_LIG_TOPO_F_RECAL afin de pouvroi revenir à un état antérieur.
*/

create or replace TRIGGER B_UDX_TA_LIG_TOPO_F_RECAL
    BEFORE UPDATE OR DELETE ON GEO.TA_LIG_TOPO_F_RECAL
    FOR EACH ROW
DECLARE
    username varchar(30);
    BEGIN
        SELECT sys_context('USERENV','OS_USER') into username from dual;  
        IF UPDATING THEN
             INSERT INTO GEO.TA_LIG_TOPO_F_RECAL_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_LIG_OFFSET_D, GEO_LIG_OFFSET_G, GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
            VALUES( :old.objectid,
                :old.cla_inu,
                :old.geo_ref,
                :old.geo_insee,
                :old.geom,
                :old.geo_dv,
                :old.geo_df,
                :old.geo_texte,
                :old.geo_lig_offset_d,
                :old.geo_lig_offset_g,
                :old.geo_type,
                username,
                sysdate,
                1
            );
        END IF;
        IF DELETING THEN
            INSERT INTO GEO.TA_LIG_TOPO_F_RECAL_LOG(FID_IDENTIFIANT, CLA_INU, GEO_REF, GEO_INSEE, GEOM, GEO_DV, GEO_DF, GEO_TEXTE, GEO_LIG_OFFSET_D, GEO_LIG_OFFSET_G, GEO_TYPE, GEO_NMN, GEO_DM, MODIFICATION) 
            VALUES( :old.objectid,
                :old.cla_inu,
                :old.geo_ref,
                :old.geo_insee,
                :old.geom,
                :old.geo_dv,
                :old.geo_df,
                :old.geo_texte,
                :old.geo_lig_offset_d,
                :old.geo_lig_offset_g,
                :old.geo_type,
                username,
                sysdate,
                0
            );
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                mail.sendmail('geotrigger@lillemetropole.fr',username || ' a provoque l''erreur : ' || SQLERRM,'ERREUR TRIGGER - geo/prod.B_UDX_TA_LIG_TOPO_F_RECAL','bjacq@lillemetropole.fr');
    END;