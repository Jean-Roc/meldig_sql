-- Requete sql necessaire à la l'insertion de la nomenclature OCS2D


-- 1. Insertion de la source dans TA_SOURCE
MERGE INTO ta_source s
USING 
    (
    	SELECT 'OCS2D' AS nom,'Le référentiel OCS2D est une base de données diachronique d''occupation du sol en 2 dimensions sur les départements du Nord et du PAS-de-Calais. Pour chaque portion de territoire interprété, il décrit de façon précise le couvert du sol et l''usage du sol.' AS description FROM DUAL
    ) temp
ON (temp.nom = s.nom_source
AND temp.description = s.description)
WHEN NOT MATCHED THEN
INSERT (s.nom_source,s.description)
VALUES (temp.nom,temp.description)
;


-- 2. Insertion de la provenance dans TA_PROVENANCE
MERGE INTO ta_provenance p
USING
    (
    	SELECT 'https://www.geo2france.fr' AS url,'Données en téléchargement libre' AS methode_acquisition FROM DUAL
   	) temp
ON (p.url = temp.url
AND p.methode_acquisition = temp.methode_acquisition)
WHEN NOT MATCHED THEN
INSERT (p.url,p.methode_acquisition)
VALUES(temp.url,temp.methode_acquisition)
;


-- 3. Insertion des données dans TA_DATE_ACQUISITION
MERGE INTO ta_date_acquisition a
USING
	(
		SELECT TO_DATE('06/04/2020') AS DATE_ACQUISITION, TO_DATE('01/01/2005') AS MILLESIME,'rjault' AS OBTENTEUR FROM DUAL
		UNION SELECT TO_DATE('06/04/2020') AS DATE_ACQUISITION, TO_DATE('01/01/2015') AS MILLESIME,'rjault' AS OBTENTEUR FROM DUAL
	) temp
ON (temp.date_acquisition = a.date_acquisition
AND temp.millesime = a.millesime)
WHEN NOT MATCHED THEN
INSERT (a.date_acquisition,a.millesime)
VALUES (temp.date_acquisition,temp.millesime)
;


-- 4. Insertion des données dans TA_ORGANISME
MERGE INTO ta_organisme a
USING
	(
		SELECT 'PPIGE' AS ACRONYME, 'Plateforme Publique de l''Information Géographique du Nord-PAS de Calais' AS NOM_ORGANISME FROM DUAL
	) temp
ON (a.acronyme = temp.acronyme)
WHEN NOT MATCHED THEN
INSERT (a.acronyme,a.nom_organisme)
VALUES(temp.acronyme,temp.nom_organisme)
;


-- 5. Insertion des données dans TA_ECHELLE
MERGE INTO ta_echelle e
USING
	(
		SELECT '5000' AS VALEUR FROM DUAL
	) temp
ON (e.valeur = temp.valeur)
WHEN NOT MATCHED THEN
INSERT (e.valeur)
VALUES(temp.valeur)
;


-- 6. Insertion des données dans TA_METADONNEE pour le millesime 2005
MERGE INTO ta_metadonnee m
USING
	(
		SELECT 
		    s.objectid AS SOURCE,
		    a.objectid AS ACQUISITION,
		    p.objectid AS PROVENANCE
		FROM
		    ta_source s,
		    ta_date_acquisition a,
		    ta_provenance p
		WHERE
		    (s.nom_source = 'OCS2D'
		AND
		    a.millesime IN ('01/01/2005')
		AND
		    a.date_acquisition = '06/04/2020'
		AND
		    p.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2005')
		OR
			(s.nom_source = 'OCS2D'
		AND
		    a.millesime IN ('01/01/2015')
		AND
		    a.date_acquisition = '06/04/2020'
		AND
		    p.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2015')
	) temp
ON (temp.SOURCE = m.fid_source
AND temp.ACQUISITION = m.fid_acquisition
AND temp.PROVENANCE = m.fid_provenance)
WHEN NOT MATCHED THEN
INSERT (fid_source,fid_acquisition,fid_provenance)
VALUES(temp.SOURCE,temp.ACQUISITION,temp.PROVENANCE)
;

-- 7. Insertion des données dans la table TA_METADONNEE_RELATION_ORGANISME
MERGE INTO ta_metadonnee_relation_organisme a
USING
    (
        SELECT
            a.objectid AS fid_metadonnee,
            e.objectid AS fid_organisme
        FROM
            ta_metadonnee a
        INNER JOIN ta_source b ON b.objectid = a.fid_source
        INNER JOIN ta_date_acquisition c ON a.fid_acquisition = c.objectid
        INNER JOIN ta_provenance d ON a.fid_provenance = d.objectid,
            ta_organisme e
        WHERE
            (b.nom_source = 'OCS2D'
        AND
            c.date_acquisition = '06/04/2020'
        AND
            c.millesime IN ('01/01/2005')
        AND
            d.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2005'
        AND
            e.nom_organisme IN ('Plateforme Publique de l''Information Géographique du Nord-PAS de Calais'))
        OR
        	(b.nom_source = 'OCS2D'
        AND
            c.date_acquisition = '06/04/2020'
        AND
            c.millesime IN ('01/01/2015')
        AND
            d.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2015'
        AND
            e.nom_organisme IN ('Plateforme Publique de l''Information Géographique du Nord-PAS de Calais'))
    )b
ON(a.fid_metadonnee = b.fid_metadonnee
AND a.fid_organisme = b.fid_organisme)
WHEN NOT MATCHED THEN
INSERT(a.fid_metadonnee, a.fid_organisme)
VALUES(b.fid_metadonnee, b.fid_organisme)
;

-- 8. Insertion des données dans la table TA_METADONNEE_RELATION_ECHELLE
MERGE INTO ta_metadonnee_relation_echelle a
USING
    (
		SELECT
		    a.objectid AS fid_metadonnee,
		    g.objectid AS fid_echelle
		FROM
		    ta_metadonnee a
		INNER JOIN ta_source b ON b.objectid = a.fid_source
		INNER JOIN ta_date_acquisition c ON a.fid_acquisition = c.objectid
		INNER JOIN ta_provenance d ON a.fid_provenance = d.objectid
		INNER JOIN ta_metadonnee_relation_organisme e ON e.fid_metadonnee = a.objectid
		INNER JOIN ta_organisme f ON f.objectid = e.fid_organisme,
		    ta_echelle g
        WHERE
            (b.nom_source = 'OCS2D'
        AND
            c.date_acquisition = '06/04/2020'
        AND
            c.millesime IN ('01/01/2005')
        AND
            d.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2005'
        AND
            f.nom_organisme IN ('Plateforme Publique de l''Information Géographique du Nord-PAS de Calais')
		AND
		    g.valeur IN ('5000')
            )
        OR
        	(b.nom_source = 'OCS2D'
        AND
            c.date_acquisition = '06/04/2020'
        AND
            c.millesime IN ('01/01/2015')
        AND
            d.url = 'https://www.geo2france.fr/ckan/dataset/occupation-du-sol-en-deux-dimensions-ocs2d-nord-pas-de-calais-2015'
        AND
            f.nom_organisme IN ('Plateforme Publique de l''Information Géographique du Nord-PAS de Calais')
		AND
		    g.valeur IN ('5000')
        )
    )b
ON(a.fid_metadonnee = b.fid_metadonnee
AND a.fid_echelle = b.fid_echelle)
WHEN NOT MATCHED THEN
INSERT(a.fid_metadonnee, a.fid_echelle)
VALUES(b.fid_metadonnee, b.fid_echelle)
;


--------------------------------------------------------------------------------
-- INSERTION DE LA NOMENCLATURE COUVERT USAGE DES DONNEES OCS2D
--------------------------------------------------------------------------------

-- 9. Vue simplifiant la nomenclature OCS2D usage pour faciliter sa normalisation
CREATE VIEW ocs2d_nomenclature_couvert_usage AS
SELECT DISTINCT
	niv_0_libelle_court AS libelle_court, 
	niv_0_libelle libelle_long,
	'niv_0' AS niveau
FROM oc_us_ocs2d
UNION ALL
SELECT DISTINCT 
	niv_1_libelle_court AS libelle_court, 
	niv_1_libelle libelle_long,
	'niv_1' AS niveau
FROM oc_us_ocs2d
UNION ALL
SELECT DISTINCT 
	niv_2_libelle_court AS libelle_court, 
	niv_2_libelle libelle_long,
	'niv_2' AS niveau
FROM oc_us_ocs2d
UNION ALL
SELECT DISTINCT 
	niv_3_libelle_court AS libelle_court, 
	niv_3_libelle AS libelle_long,
	'niv_3' AS niveau
FROM
	oc_us_ocs2d;


-- 10. Insertion des libelles courts dans TA_LIBELLE_COURT
MERGE INTO ta_libelle_court tlc
USING
	(
	SELECT DISTINCT
		libelle_court AS valeur
	FROM
		ocs2d_nomenclature_couvert_usage
	) temp
ON (temp.valeur = tlc.valeur)
WHEN NOT MATCHED THEN
INSERT (tlc.valeur)
VALUES (temp.valeur)
;


-- 11. Insertion des libelles longs dans TA_LIBELLE_LONG
MERGE INTO ta_libelle_long tl
USING
	(
	SELECT DISTINCT
		libelle_long AS valeur
	FROM
		ocs2d_nomenclature_couvert_usage
	) temp
ON (temp.valeur = tl.valeur)
WHEN NOT MATCHED THEN
INSERT (tl.valeur)
VALUES (temp.valeur)
;


-- 12. Insertion de la famille dans TA_FAMILLE
MERGE INTO TA_FAMILLE tf
USING
	(
		SELECT 'OCS2D' AS valeur FROM DUAL
	)temp
ON (temp.valeur = tf.valeur)
WHEN NOT MATCHED THEN
INSERT (tf.valeur)
VALUES (temp.valeur)
;


-- 13. Insertion des relations dans TA_FAMILLE_LIBELLE
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
		f.famille = 'OCS2D' AND
		l.libelle_long IN
			(
			SELECT DISTINCT
				libelle_long
			FROM
				ocs2d_nomenclature_couvert_usage
			)
		) temp
ON (temp.fid_famille = tfl.fid_famille
AND temp.fid_libelle_long = tfl.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (tfl.fid_famille,tfl.fid_libelle_long)
VALUES (temp.fid_famille,temp.fid_libelle_long)
;


-- 14. Creation vue des relations
CREATE VIEW oc_us_ocs2d_relation AS
SELECT DISTINCT
    niv_1_libelle_court AS lcf,
    niv_1_libelle AS llf,
    niv_0_libelle_court AS lcp,
    niv_0_libelle AS llp
FROM oc_us_ocs2d
UNION ALL select distinct
    niv_2_libelle_court AS lcf,
    niv_2_libelle AS llf,
    niv_1_libelle_court AS lcp,
    niv_1_libelle AS llf
FROM oc_us_ocs2d
UNION ALL select distinct
    niv_3_libelle_court AS lcf,
    niv_3_libelle AS llf,
    niv_2_libelle_court AS lcp,
    niv_2_libelle AS llf
FROM oc_us_ocs2d;


-- 15. creation de la table FUSION_OCS2D_COUVERT_USAGE pour normaliser les données.
CREATE GLOBAL TEMPORARY TABLE FUSION_OCS2D_COUVERT_USAGE AS
(SELECT
    d.objectid AS objectid,
    b.objectid AS fid_libelle_long,
    a.libelle_long,
    c.objectid AS fid_libelle_court,
    a.libelle_court,
    a.niveau
FROM
    ta_libelle d,
	ocs2d_nomenclature_couvert_usage a
JOIN TA_LIBELLE_LONG b ON b.valeur = a.libelle_long
LEFT JOIN TA_LIBELLE_COURT c ON c.valeur = a.libelle_court);


-- 16. Insertion des données dans la table temporaire fusion utilisation de la séquence de la table TA_LIBELLE
INSERT INTO FUSION_OCS2D_COUVERT_USAGE
SELECT
-- attention à la séquence utilisée
    ISEQ$$_78716.nextval AS objectid,
-- attention à la séquence utilisée
    b.objectid AS fid_libelle_long,
    a.libelle_long,
    c.objectid AS fid_libelle_court,
    a.libelle_court,
    a.niveau
FROM
    ocs2d_nomenclature_couvert_usage a
JOIN TA_LIBELLE_LONG b ON b.valeur = a.libelle_long
LEFT JOIN TA_LIBELLE_COURT c ON c.valeur = a.libelle_court;


-- 17. Insertion des données dans ta_libelle
MERGE INTO ta_libelle l
USING
	(
	SELECT
		objectid, 
		fid_libelle_long
	FROM FUSION_OCS2D_COUVERT_USAGE
	) temp
ON (temp.objectid = l.objectid
AND temp.fid_libelle_long = l.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (l.objectid,l.fid_libelle_long)
VALUES (temp.objectid,temp.fid_libelle_long)
;


-- 18. Insertion des données dans ta_correspondance_libelle
MERGE INTO ta_correspondance_libelle tc
USING
	(
	SELECT
		objectid, 
		fid_libelle_court
	FROM FUSION_OCS2D_COUVERT_USAGE
	) temp
ON (temp.objectid = tc.fid_libelle
AND temp.fid_libelle_court = tc.fid_libelle_court)
WHEN NOT MATCHED THEN
INSERT (tc.fid_libelle,tc.fid_libelle_court)
VALUES (temp.objectid,temp.fid_libelle_court)
;


-- 19. Insertion des données dans ta_relation_libelle
MERGE INTO ta_relation_libelle tr
USING 
	(
	SELECT
	    ff.objectid fid_libelle_fils,
	    fp.objectid fid_libelle_parent
	FROM
	    FUSION_OCS2D_COUVERT_USAGE ff,
	    FUSION_OCS2D_COUVERT_USAGE fp,
	    oc_us_ocs2d_relation o
	WHERE
	        ff.libelle_court = o.lcf
	    AND
	        ff.libelle_long = o.llf
	    AND
	        fp.libelle_court =o.lcp
	    AND
	        fp.libelle_long =o.llp
	    AND
	    (
	        (ff.niveau = 'niv_1' AND fp.niveau = 'niv_0')
	    OR 
	        (ff.niveau = 'niv_2' AND fp.niveau = 'niv_1')
	    OR 
	        (ff.niveau = 'niv_3' AND fp.niveau = 'niv_2')
	    )
	)temp
ON (temp.fid_libelle_fils = tr.fid_libelle_fils
AND temp.fid_libelle_parent = tr.fid_libelle_parent)
WHEN NOT MATCHED THEN
INSERT (tr.fid_libelle_fils,tr.fid_libelle_parent)
VALUES (temp.fid_libelle_fils,temp.fid_libelle_parent)
;


-- 20. Suppression des tables et des vues utilisés seulement pour l'insertion de la nomenclature.
-- 20.1. Suppression de la table temporaire oc_us_ocs2d
DROP TABLE oc_us_ocs2d CASCADE CONSTRAINTS PURGE;

-- 20.2. Suppression de la table temporaire FUSION_OCS2D_COUVERT_USAGE
DROP TABLE FUSION_OCS2D_COUVERT_USAGE CASCADE CONSTRAINTS PURGE;

-- 20.3. Suppression de la vue oc_us_ocs2d_relation
DROP VIEW oc_us_ocs2d_relation CASCADE CONSTRAINTS;

-- 20.4. Suppression de la vue ocs2d_nomenclature_couvert_usage
DROP VIEW ocs2d_nomenclature_couvert_usage CASCADE CONSTRAINTS;