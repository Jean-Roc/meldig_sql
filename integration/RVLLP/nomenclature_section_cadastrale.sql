-- Insertion de la nomenclature des sections cadastrales

-- 1. Insertion de la source dans G_GEO.TA_SOURCE
MERGE INTO G_GEO.TA_SOURCE a
USING 
    (
        SELECT 'PCI' AS nom_source, 'Plan Cadastral Informatisé' AS description FROM DUAL
    ) b
ON (UPPER(a.nom_source) = UPPER(b.nom_source)
    AND UPPER(a.description) = UPPER(b.description))
WHEN NOT MATCHED THEN
INSERT (a.nom_source,a.description)
VALUES (b.nom_source,b.description)
;


-- 2. Insertion de la provenance de la données dans G_GEO.TA_PROVENANCE
MERGE INTO G_GEO.TA_PROVENANCE a
USING
    (
        SELECT 'https://geoservices.ign.fr/documentation/diffusion/telechargement-donnees-libres.html#contoursiris' AS url, 'Donnée à télécharger en libre accès' AS methode_acquisition FROM DUAL
    ) b
ON (UPPER(a.url) = UPPER(b.url)
    AND UPPER(a.methode_acquisition) = UPPER(b.methode_acquisition))
WHEN NOT MATCHED THEN
INSERT (a.url,a.methode_acquisition)
VALUES(b.url,b.methode_acquisition)
;


-- 3. Insertion des données dans TA_DATE_ACQUISITION
MERGE INTO G_GEO.TA_DATE_ACQUISITION a
USING
    (
        SELECT TO_DATE(SYSDATE,'dd/mm/yy') AS DATE_ACQUISITION, TO_DATE('01/01/17') AS MILLESIME, SYS_CONTEXT('USERENV', 'OS_USER') AS NOM_OBTENTEUR FROM DUAL
    ) b
ON (a.date_acquisition = b.date_acquisition
    AND a.millesime = b.millesime
    AND a.nom_obtenteur = b.nom_obtenteur)
WHEN NOT MATCHED THEN
INSERT (a.date_acquisition,a.millesime, a.nom_obtenteur)
VALUES (b.date_acquisition, b.millesime, b.nom_obtenteur)
;


-- 4. Insertion des données dans TA_ORGANISME
MERGE INTO G_GEO.TA_ORGANISME a
USING
    (
        SELECT 'DGFIP' AS ACRONYME, 'Direction Générale des Finances Publiques' AS NOM_ORGANISME FROM DUAL
    ) temp
ON (UPPER(a.acronyme) = UPPER(temp.acronyme)
    AND UPPER(a.nom_organisme) = UPPER(b.nom_organisme))
WHEN NOT MATCHED THEN
INSERT (a.acronyme,a.nom_organisme)
VALUES(temp.acronyme,temp.nom_organisme)
;


-- 5. Insertion des données dans TA_METADONNEE
MERGE INTO G_GEO.TA_METADONNEE a
USING
    (
        SELECT 
            a.objectid AS FID_SOURCE,
            b.objectid AS FID_ACQUISITION,
            c.objectid AS FID_PROVENANCE
        FROM
            G_GEO.TA_SOURCE a,
            G_GEO.TA_DATE_ACQUISITION b,
            G_GEO.TA_PROVENANCE c
        WHERE
            a.nom_source = 'PCI'
        AND
            b.millesime IN ('01/01/2017')
        AND
            b.date_acquisition = TO_DATE(SYSDATE,'dd/mm/yy')
        AND
            b.nom_obtenteur = SYS_CONTEXT('USERENV', 'OS_USER')
        AND
            c.url = 'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels'
    )temp
ON (a.fid_source = temp.fid_source
AND a.fid_acquisition = temp.fid_acquisition
AND a.fid_provenance = temp.fid_provenance)
WHEN NOT MATCHED THEN
INSERT (a.fid_source, a.fid_acquisition, a.fid_provenance)
VALUES (temp.fid_source, temp.fid_acquisition, temp.fid_provenance)
;


-- 6. Insertion des données dans la table G_GEO.TA_METADONNEE_RELATION_ORGANISME
MERGE INTO G_GEO.TA_METADONNEE_RELATION_ORGANISME a
USING
    (
        SELECT
            a.objectid AS fid_metadonnee,
            e.objectid AS fid_organisme
        FROM
            G_GEO.TA_METADONNEE a
        INNER JOIN G_GEO.TA_SOURCE b ON b.objectid = a.fid_source
        INNER JOIN G_GEO.TA_DATE_ACQUISITION c ON a.fid_acquisition = c.objectid
        INNER JOIN G_GEO.TA_PROVENANCE d ON a.fid_provenance = d.objectid,
            G_GEO.TA_ORGANISME e
        WHERE
            b.nom_source = 'PCI'
        AND
            c.millesime IN ('01/01/2017')
        AND
            c.date_acquisition = TO_DATE(SYSDATE,'dd/mm/yy')
        AND
            d.url = 'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels'
        AND
            e.nom_organisme = 'Direction Générale des Finances Publiques'
    )b
ON(a.fid_metadonnee = b.fid_metadonnee
    AND a.fid_organisme = b.fid_organisme)
WHEN NOT MATCHED THEN
INSERT(a.fid_metadonnee, a.fid_organisme)
VALUES(b.fid_metadonnee, b.fid_organisme)
;


-- 9. Insertion de la nomenclature dans la table G_GEO.TA_LIBELLE LONG
MERGE INTO G_GEO.TA_LIBELLE_LONG a
USING 
    (
    SELECT 'section' AS VALEUR FROM dual
    UNION
    SELECT 'prefixe' AS VALEUR FROM dual
    UNION
    SELECT 'code insee' AS VALEUR FROM dual
    ) b
  ON (UPPER(a.VALEUR) = UPPER(b.VALEUR))
  WHEN NOT MATCHED THEN
  INSERT (a.VALEUR)
  VALUES (b.VALEUR)
;


-- 9. Insertion de la nomenclature dans la table G_GEO.TA_LIBELLE LONG
MERGE INTO G_GEO.TA_LIBELLE_COURT a
USING 
    (
    SELECT 'pre' AS VALEUR FROM dual
    ) b
  ON (UPPER(a.VALEUR) = UPPER(b.VALEUR))
  WHEN NOT MATCHED THEN
  INSERT (a.VALEUR)
  VALUES (b.VALEUR)
;


-- 11. Insertion des familles utilisée par les données IRIS dans la table G_GEO.TA_FAMILLE.
MERGE INTO G_GEO.TA_FAMILLE a
USING 
    (
    SELECT 'identifiants de zone cadastrale' AS VALEUR FROM dual
    ) b
ON (UPPER(a.VALEUR) = UPPER(b.VALEUR))
WHEN NOT MATCHED THEN
INSERT (a.VALEUR)
VALUES (b.VALEUR);


-- 12. Insertion des correspondances famille libelle dans G_GEO.TA_FAMILLE_LIBELLE;
MERGE INTO G_GEO.TA_FAMILLE_LIBELLE a
USING 
    (
    SELECT
        a.objectid AS fid_famille,
        b.objectid AS fid_libelle_long
    FROM
        G_GEO.TA_FAMILLE a,
        G_GEO.TA_LIBELLE_LONG b
    WHERE
        UPPER(a.VALEUR) = 'IDENTIFIANTS DE ZONE CADASTRALE' AND UPPER(b.VALEUR) = 'PREFIXE'
        OR UPPER(a.VALEUR) = 'IDENTIFIANTS DE ZONE CADASTRALE' AND UPPER(b.VALEUR) = 'SECTION'
        OR UPPER(a.VALEUR) = 'IDENTIFIANTS DE ZONE ADMINISTRATIVE' AND UPPER(b.VALEUR) = 'CODE_INSEE'
    ) b
ON (a.fid_famille = b.fid_famille
    AND a.fid_libelle_long = b.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (a.fid_famille,a.fid_libelle_long)
VALUES (b.fid_famille,b.fid_libelle_long);


-- 13. Insertion des fid_libelle_long dans la table G_GEO.TA_LIBELLE
MERGE INTO G_GEO.TA_LIBELLE a
USING
    (
    SELECT
        a.objectid AS fid_libelle_long
    FROM
        G_GEO.TA_LIBELLE_LONG a
    INNER JOIN
        G_GEO.TA_FAMILLE_LIBELLE b ON b.fid_libelle_long = a.objectid
    INNER JOIN
        G_GEO.TA_FAMILLE c ON c.objectid = b.fid_famille
    WHERE
        UPPER(c.VALEUR) = 'IDENTIFIANTS DE ZONE CADASTRALE'
    OR UPPER(c.VALEUR) = 'IDENTIFIANTS DE ZONE ADMINISTRATIVE'
    )b
ON(a.fid_libelle_long = b.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (a.fid_libelle_long)
VALUES (b.fid_libelle_long);


-- 14. Insertion des données dans la table G_GEO.TA_LIBELLE_CORRESPONDANCE
MERGE INTO G_GEO.TA_LIBELLE_CORRESPONDANCE a
USING 
    (
        SELECT
            a.objectid AS fid_libelle,
            b.objectid AS fid_libelle_court
        FROM
            G_GEO.TA_LIBELLE_COURT b,        
            G_GEO.TA_LIBELLE a
        INNER JOIN 
            G_GEO.TA_LIBELLE_LONG c ON c.objectid = a.fid_libelle_long
        INNER JOIN
            G_GEO.TA_FAMILLE_LIBELLE d ON d.fid_libelle_long = c.objectid
        INNER JOIN
            G_GEO.TA_FAMILLE e ON e.objectid = d.fid_famille
        WHERE
            UPPER(b.VALEUR) = 'PRE' AND UPPER(c.VALEUR) = 'PREFIXE'
        AND UPPER(e.VALEUR) = 'IDENTIFIANTS DE ZONE CADASTRALE' 
    )b
ON(a.fid_libelle = b.fid_libelle
    AND a.fid_libelle_court = b.fid_libelle_court)
WHEN NOT MATCHED THEN
INSERT(a.fid_libelle, a.fid_libelle_court)
VALUES(b.fid_libelle, b.fid_libelle_court);