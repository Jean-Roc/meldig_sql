-- Fichier de requete de normalisation des données des sections cadastrale
-- 1. Point de sauvegarde
SET SERVEROUTPUT ON
BEGIN
SAVEPOINT POINT_SAUVERGARDE_NORMALISATION_1;


-- 2. Insertion des codes SECTION dans G_GEO.TA_CODE
MERGE INTO G_GEO.TA_CODE a
USING 
    (
    SELECT
        DISTINCT(a.SECTION) AS valeur,
        b.objectid AS fid_libelle
    FROM 
        S_EDIGEO.SECTION_CADASTRALE a,
        G_GEO.TA_LIBELLE b
    INNER JOIN G_GEO.TA_LIBELLE_LONG c ON b.fid_libelle_long = c.objectid
    INNER JOIN G_GEO.TA_FAMILLE_LIBELLE d ON d.fid_libelle_long = c.objectid
    INNER JOIN G_GEO.TA_FAMILLE e ON e.objectid = d.fid_famille
    WHERE
        UPPER(c.valeur) = 'SECTION'
    AND UPPER(e.valeur) = 'IDENTIFIANTS DE ZONE CADASTRALE'
    ) b
ON (a.valeur = b.valeur
    AND a.fid_libelle = b.fid_libelle)
WHEN NOT MATCHED THEN
INSERT (a.valeur,a.fid_libelle)
VALUES (b.valeur,b.fid_libelle);


-- 3. Insertion des codes PREFIXE dans G_GEO.TA_CODE
MERGE INTO G_GEO.TA_CODE a
USING 
    (
    SELECT
        DISTINCT(a.PRE) AS valeur,
        b.objectid AS fid_libelle
    FROM 
        S_EDIGEO.SECTION_CADASTRALE a,
        G_GEO.TA_LIBELLE b
    INNER JOIN G_GEO.TA_LIBELLE_LONG c ON b.fid_libelle_long = c.objectid
    INNER JOIN G_GEO.TA_FAMILLE_LIBELLE d ON d.fid_libelle_long = c.objectid
    INNER JOIN G_GEO.TA_FAMILLE e ON e.objectid = d.fid_famille
    WHERE
        UPPER(c.valeur) = 'PREFIXE'
    AND UPPER(e.valeur) = 'IDENTIFIANTS DE ZONE CADASTRALE'
    ) b
ON (a.valeur = b.valeur
    AND a.fid_libelle = b.fid_libelle)
WHEN NOT MATCHED THEN
INSERT (a.valeur,a.fid_libelle)
VALUES (b.valeur,b.fid_libelle);


-- 4. Insertion des géométrie des SECTION CADASTRALE dans G_GEO.TA_SECTION_CADASTRALE_GEOM
INSERT INTO G_DGFIP.TA_SECTION_CADASTRALE_GEOM
SELECT
    geom
FROM
    S_EDIGEO.SECTION_CADASTRALE
-- Sous requete dans le WHERE pour n'insérer que les nouvelles géométrie pas encore présente dans la table
WHERE
    id_sec not IN
        (
        SELECT
            a.id_sec
        FROM
            S_EDIGEO.SECTION_CADASTRALE a,
            G_DGFIP.TA_SECTION_CADASTRALE_GEOM b
        WHERE
            ORA_HASH(TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(SDO_GEOM.SDO_CENTROID(a.geom)))) = ORA_HASH(TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(SDO_GEOM.SDO_CENTROID(b.geom))))
        )
;

-- 5. Normalisation des sections cadastrale dans la table TA_SECTION_CADASTRALE.
MERGE INTO G_DGFIP.TA_SECTION_CADASTRALE a
USING 
    (
    SELECT
            b.objectid AS fid_code,
            g.objectid AS fid_section,
            l.objectid AS fid_prefixe,
            n.objectid AS fid_metadonnee,
            o.objectid AS fid_geom
        FROM
            S_EDIGEO.SECTION_CADASTRALE a
            -- selection du fid_code
            INNER JOIN G_GEO.TA_CODE b ON b.valeur = a.section
            INNER JOIN G_GEO.TA_LIBELLE c ON c.objectid = b.fid_libelle
            INNER JOIN G_GEO.TA_LIBELLE_LONG d ON d.objectid = c.fid_libelle_long
            INNER JOIN G_GEO.TA_FAMILLE_LIBELLE e ON e.fid_libelle_long = d.objectid
            INNER JOIN G_GEO.TA_FAMILLE f ON f.objectid = e.fid_famille
            -- selection du fid_section
            INNER JOIN G_GEO.TA_CODE g ON g.valeur = a.section
            INNER JOIN G_GEO.TA_LIBELLE h ON h.objectid = g.fid_libelle
            INNER JOIN G_GEO.TA_LIBELLE_LONG i ON i.objectid = h.fid_libelle_long
            INNER JOIN G_GEO.TA_FAMILLE_LIBELLE j ON j.fid_libelle_long = i.objectid
            INNER JOIN G_GEO.TA_FAMILLE k ON k.objectid = j.fid_famille,
            -- selection du fid_prefixe
            INNER JOIN G_GEO.TA_CODE l ON l.valeur = a.pre
            INNER JOIN G_GEO.TA_LIBELLE m ON m.objectid = l.fid_libelle
            INNER JOIN G_GEO.TA_LIBELLE_LONG n ON n.objectid = m.fid_libelle_long
            INNER JOIN G_GEO.TA_FAMILLE_LIBELLE o ON o.fid_libelle_long = n.objectid
            INNER JOIN G_GEO.TA_FAMILLE p ON p.objectid = o.fid_famille,
            -- selection des metadonnees
            G_GEO.TA_METADONNEE q,
            -- selection des géométrie
            S_EDIGEO.TA_SECTION_CADASTRALE r
        WHERE
            -- fid_code pour les codes communes
            UPPER(d.valeur) = 'CODE INSEE'
        AND
            UPPER(f.valeur) = 'IDENTIFIANTS DE ZONE ADMINISTRATIVE'
        AND
            -- fid_code pour les codes sections
            UPPER(i.valeur) = 'SECTION'
        AND
            UPPER(k.valeur) = 'IDENTIFIANTS DE ZONE CADASTRALE'
        AND
            -- fid_code pour les codes sections
            UPPER(i.valeur) = 'PREFIXE'
        AND
            UPPER(k.valeur) = 'IDENTIFIANTS DE ZONE CADASTRALE'
        -- sous requete AND pour insérer le fid_métadonnee au millesime le plus récent pour la donnée considérée
        AND 
            r.objectid IN
                (
                SELECT
                    a.objectid AS id_mtd
                FROM
                    G_GEO.TA_METADONNEE a
                    INNER JOIN G_GEO.TA_SOURCE b ON a.fid_source = b.objectid
                    INNER JOIN G_GEO.TA_DATE_ACQUISITION c ON c.objectid = a.fid_acquisition
                WHERE
                    c.millesime IN(
                                SELECT
                                    MAX(b.millesime) as MILLESIME
                                FROM
                                    G_GEO.TA_METADONNEE a
                                INNER JOIN G_GEO.TA_DATE_ACQUISITION b ON a.fid_acquisition = b.objectid 
                                INNER JOIN G_GEO.TA_SOURCE c ON c.objectid = a.fid_source
                                WHERE c.nom_source = 'PCI'
                                )
                AND
                    b.nom_source = 'PCI'
                )
        -- sous requete AND pour insérer le fid_iris_geom de la bonne géométrie de l'IRIS.
        AND
            ORA_HASH(TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(SDO_GEOM.SDO_CENTROID(a.geom)))) = ORA_HASH(TO_CHAR(SDO_UTIL.TO_WKTGEOMETRY(SDO_GEOM.SDO_CENTROID(r.geom))))
    )b
ON (a.fid_code = b.fid_code
    AND a.fid_section = b.fid_section
    AND a.fid_prefixe = b.fid_prefixe
    AND a.fid_metadonnee = b.fid_metadonnee
    AND a.fid_iris_geom = b.fid_geom )
WHEN NOT MATCHED THEN
INSERT (a.fid_code,a.fid_section,a.fid_prefixe,a.fid_metadonnee,a.fid_geom)
VALUES (b.fid_code,b.fid_section,b.fid_prefixe,b.fid_metadonnee,b.fid_geom)
;

COMMIT;
-- 7. En cas d'exeption levée, faire un ROLLBACK
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_NORMALISATION_1;
END;
/