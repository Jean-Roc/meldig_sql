/*
Conversion des données des points de vigilance.
Objectif : passer d'un format de test en shape à un format de prod inclu dans une base de données relationnelle.
Le champ priorite correspond à plusieurs informations différentes qui sont divisées entre les FK de la table (champs préfixés par fid_)

1. Suppression des doublons géométriques ;
2. Ajout des champs permettant de catégoriser les points de vigilance ;
3. Mise à jour des nouveaux champs en fonction de la valeur du champ priorite ;
4. Insertion des données dans la table G_GESTIONGEO.TA_GG_POINT_VIGILANCE ;
5. En cas d'exeption levée, faire un ROLLBACK ;
*/

SET SERVEROUTPUT ON
BEGIN
SAVEPOINT POINT_SAUVERGARDE_CONVERSION_PTS_VIGILANCE;
-- 1. Suppression des doublons géométriques ;
DELETE 
FROM
    G_GESTIONGEO.TEMP_POINT_VIGILANCE t
WHERE 
    t.ogr_fid IN(
        SELECT
            a.ogr_fid
        FROM
            G_GESTIONGEO.TEMP_POINT_VIGILANCE a,
            G_GESTIONGEO.TEMP_POINT_VIGILANCE b
        WHERE
            a.ora_geometry.SDO_POINT.X = b.ora_geometry.SDO_POINT.X
            AND a.ora_geometry.SDO_POINT.Y = b.ora_geometry.SDO_POINT.Y
            AND a.ogr_fid < b.ogr_fid
    );

-- 3. Mise à jour des nouveaux champs en fonction de la valeur du champ priorite ;
/*
Le tableau de correspondance ayant permis de créer ces règles se trouve ici :
\\volt\infogeo\UF_Acquisition\test_point_vigilance\règles_transposition_donnes_shape_en_base.xlsx
*/
    UPDATE G_GESTIONGEO.TEMP_POINT_VIGILANCE
    SET
        fid_type_signalement =(
            CASE
                WHEN "priorite" IN(1, 3, 5)
                    THEN 369
                WHEN "priorite" = 2
                    THEN 372
                WHEN "priorite" = 9
                    THEN 354
                WHEN "priorite" IN(11, 12)
                    THEN 356
            END
        ),
        fid_verification =(
            CASE
                WHEN "priorite" IN(1, 3, 5, 9)
                    THEN 364
                WHEN "priorite" = 2
                    THEN 355
                WHEN "priorite" IN(11, 12)
                    THEN 371
            END
        ),
        fid_libelle =(
            CASE
                WHEN "priorite" = 5
                    THEN 359
                WHEN "priorite" IN(1, 2, 3, 9, 11, 12)
                    THEN 368
            END
        ),
        fid_lib_statut =(
            CASE
                WHEN "priorite" = 1
                    THEN 358
                WHEN "priorite" IN(2, 3, 5, 9, 11, 12)
                    THEN 362
            END
        ),
        commentaire = "commentair",
        fid_type_point = (
                            SELECT 
                                a.objectid 
                            FROM
                                G_GEO.TA_LIBELLE a
                                INNER JOIN G_GEO.TA_LIBELLE_LONG b ON a.fid_libelle_long = b.objectid
                            WHERE
                                UPPER(b.valeur) = UPPER('point de vigilance'))
    ;

-- 4. Insertion des données dans la table G_GESTIONGEO.TA_GG_POINT_VIGILANCE ;
    MERGE INTO G_GESTIONGEO.TA_GG_POINT_VIGILANCE a
        USING(
            SELECT
                b.FID_TYPE_SIGNALEMENT,
                b.FID_VERIFICATION,
                b.ORA_GEOMETRY,
                b.FID_LIB_STATUT,
                b.FID_LIBELLE,
                b.COMMENTAIRE,
                b.FID_TYPE_POINT
            FROM
                G_GESTIONGEO.TEMP_POINT_VIGILANCE b
            WHERE
                b."priorite" IN(1, 2, 3, 5, 9, 11, 12)
                AND b.ORA_GEOMETRY IS NOT NULL
        )t
        ON(
            a.FID_TYPE_SIGNALEMENT = t.FID_TYPE_SIGNALEMENT
            AND a.FID_VERIFICATION = t.FID_VERIFICATION
            AND a.FID_LIB_STATUT = t.FID_LIB_STATUT
            AND a.FID_LIBELLE = t.FID_LIBELLE
            AND a.FID_TYPE_POINT = t.FID_TYPE_POINT
        )
    WHEN NOT MATCHED THEN
        INSERT(
            a.FID_TYPE_SIGNALEMENT,
            a.FID_VERIFICATION,
            a.GEOM,
            a.FID_LIB_STATUT,
            a.FID_LIBELLE,
            a.COMMENTAIRE,
            a.FID_TYPE_POINT
        )
        VALUES(
            t.FID_TYPE_SIGNALEMENT,
            t.FID_VERIFICATION,
            t.ORA_GEOMETRY,
            t.FID_LIB_STATUT,
            t.FID_LIBELLE,
            t.COMMENTAIRE,
            t.FID_TYPE_POINT
    );

	COMMIT;

-- 5. En cas d'exeption levée, faire un ROLLBACK ;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_CONVERSION_PTS_VIGILANCE;
END;
/