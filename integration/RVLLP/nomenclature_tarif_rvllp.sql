-- Fichier de requête permettant d'insérer les données des tarifs de la taxe RVLLP suivant le secteur tarifaire.

-- 1. Insertion de la source dans TA_SOURCE.
MERGE INTO ta_source a
USING
    (
    	SELECT
    		'grille tarifaire RVLLP' AS nom_source,
    		'grille tarifaire de la revision des valeurs locatives des locaux professionnels' AS description
    	FROM
    		DUAL
    ) b
ON (UPPER(a.nom_source) = UPPER(b.nom_source)
AND UPPER(a.description) = UPPER(b.description))
WHEN NOT MATCHED THEN
INSERT (a.nom_source,a.description)
VALUES (b.nom_source,b.description)
;


-- 2. Insertion de la provenance dans TA_PROVENANCE
MERGE INTO ta_provenance a
USING
    (
    	SELECT
    		'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels' AS url,
	    	'les données sont proposées en libre accès sous la forme d''un tableau ods.' AS methode_acquisition
    	FROM
    		DUAL
   	) b
ON (UPPER(a.url) = UPPER(b.url)
AND UPPER(a.methode_acquisition) = UPPER(b.methode_acquisition))
WHEN NOT MATCHED THEN
INSERT(a.url,a.methode_acquisition)
VALUES(b.url,b.methode_acquisition)
;


-- 3. Insertion des données dans TA_DATE_ACQUISITION
MERGE INTO G_GEO.TA_DATE_ACQUISITION a
USING
    (
        SELECT TO_DATE(SYSDATE,'dd/mm/yy') AS DATE_ACQUISITION, TO_DATE('01/01/20') AS MILLESIME, SYS_CONTEXT('USERENV', 'OS_USER') AS NOM_OBTENTEUR FROM DUAL
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
            a.nom_source = 'grille tarifaire RVLLP'
        AND
            b.millesime IN ('01/01/2020')
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


-- 6.Insertion des données dans la table TA_METADONNEE_RELATION_ORGANISME
MERGE INTO TA_METADONNEE_RELATION_ORGANISME a
USING
	(
		SELECT
			a.objectid AS fid_metadonnee,
            f.objectid AS fid_organisme
        FROM
            ta_metadonnee a
        INNER JOIN ta_source b ON a.fid_source = b.objectid
        INNER JOIN ta_date_acquisition c ON a.fid_acquisition = c.objectid
        INNER JOIN ta_provenance d ON a.fid_provenance = d.objectid,
            ta_organisme f
        WHERE
            b.nom_source = UPPER('GRILLE TARIFAIRE RVLLP')
        AND
            c.date_acquisition = TO_DATE(SYSDATE,'dd/mm/yy')
        AND
            c.millesime = '01/01/2020'
        AND
            d.url = 'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels'
        AND
            f.nom_organisme = UPPER('DIRECTION GENERALE DES FINANCES PUBLIQUES')
	)b
ON(a.fid_metadonnee = b.fid_metadonnee
AND a.fid_organisme = b.fid_organisme)
WHEN NOT MATCHED THEN
INSERT(a.fid_metadonnee, a.fid_organisme)
VALUES(b.fid_metadonnee, b.fid_organisme)
;