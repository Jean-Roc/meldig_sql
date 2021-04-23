-- Requete sql necessaire à la l'insertion de la nomenclature OCS2D


-- 1. Insertion de la source dans TA_SOURCE
MERGE INTO ta_source s
USING 
    (
    	SELECT 'RVLLP' AS nom_source,'Révision des valeurs locatives des locaux professionnels' AS description FROM DUAL
    ) temp
ON (UPPER(temp.nom) = UPPER(s.nom_source)
AND UPPER(temp.description) = UPPER(s.description))
WHEN NOT MATCHED THEN
INSERT (s.nom_source,s.description)
VALUES (temp.nom,temp.description)
;


-- 2. Insertion de la provenance dans TA_PROVENANCE
MERGE INTO ta_provenance p
USING
    (
    	SELECT 'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels' AS url,'Données en téléchargement libre' AS methode_acquisition FROM DUAL
   	) temp
ON (UPPER(p.url) = UPPER(temp.url)
AND UPPER(p.methode_acquisition) = UPPER(temp.methode_acquisition))
WHEN NOT MATCHED THEN
INSERT (p.url,p.methode_acquisition)
VALUES(temp.url,temp.methode_acquisition)
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
MERGE INTO ta_organisme a
USING
	(
		SELECT 'DGFIP' AS ACRONYME, 'direction générale des finances publiques' AS NOM_ORGANISME FROM DUAL
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
            a.nom_source = 'RVLLP'
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
            b.nom_source = 'RVLLP'
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


-- 7. Insertion des libelles longs dans TA_LIBELLE_LONG
MERGE INTO ta_libelle_long tl
USING
	(
	SELECT
		'secteur'
	FROM
		DUAL
	) temp
ON (UPPER(temp.valeur) = UPPER(tl.valeur))
WHEN NOT MATCHED THEN
INSERT (tl.valeur)
VALUES (temp.valeur)
;


-- 8. Insertion de la famille dans TA_FAMILLE
MERGE INTO TA_FAMILLE tf
USING
	(
		SELECT 'RVLLP' AS valeur FROM DUAL
	)temp
ON (UPPER(temp.valeur) = UPPER(tf.valeur))
WHEN NOT MATCHED THEN
INSERT (tf.valeur)
VALUES (temp.valeur)
;


-- 9. Insertion des relations dans TA_FAMILLE_LIBELLE
MERGE INTO TA_FAMILLE_LIBELLE tfl
USING
	(
	SELECT
		f.objectid fid_famille,
		l.objectid fid_libelle_long
    FROM
        ta_famille f,
        ta_libelle_long l
	WHERE 
		UPPER(f.famille) = 'RVLLP' AND
		UPPER(l.libelle_long) = 'SECTEUR'
		) temp
ON (temp.fid_famille = tfl.fid_famille
AND temp.fid_libelle_long = tfl.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (tfl.fid_famille,tfl.fid_libelle_long)
VALUES (temp.fid_famille,temp.fid_libelle_long)
;